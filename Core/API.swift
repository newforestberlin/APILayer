// The MIT License (MIT)
//
// Copyright (c) 2015 you & the gang UG(haftungsbeschränkt)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import Alamofire

// Setting the delegate is optional. If set, it can control how the API handles auth token refreshing
public protocol TokenRefreshDelegate {
    
    // For each response the delegate is asked if it implies that token refresh is neeed. Could check for HTTP status for example.
    func tokenRefreshIsIndicated(byResponse response: NSHTTPURLResponse) -> Bool
    
    // Must refresh the token and call the completion block on failure or succcess. Should do a refresh request.
    // If refresh was successful, the waiting requests are performed in order and everything goes on. If however
    // refreshing failed, all waiting requests are cancelled and the delegates tokenRefreshHasFailed() method is called,
    // so that the app can react to that (log out for example).
    func tokenRefresh(completion: (refreshWasSuccessful: Bool) -> ())
    
    // Called if token refresh has failed. In this case all waiting requests are removed and the app should react to that.
    func tokenRefreshHasFailed()
}

// Wrapper to make NSURLRequest conform to URLRequestConvertible
class RequestWrapper: URLRequestConvertible {
    let request: NSURLRequest
    init(request: NSURLRequest) {
        self.request = request
    }
    
    var URLRequest: NSURLRequest { return request }
}

// Temp solutions until Class variables are supperted in Swift
private var API_mapper = ParameterMapper()

// If this one is set it might return mock paths for router cases, in which case the API does use mock data from local filesystem
private var API_mocker: MockingProtocol?

// This queue is used to delay requests when a token refresh is needed. The requests are then performed after the refresh is done.
private var API_operations = NSOperationQueue()

// If this is set, we are currently refreshing the token
private var API_tokenRefreshOperation: NSOperation?

// The optional delegate, that controls token refresh logic
private var API_tokenRefreshDelegate: TokenRefreshDelegate?

// This class functions as the main interface to the API layer.
public class API {
    
    // A user of the API is mean to implement a subclass of ParameterWrapper and set it to this property
    public class var parameterMapper: ParameterMapper {
        get {
            return API_mapper
        }
        set {
            API_mapper = newValue
        }
    }
    
    // A user of the API is mean to implement a subclass of ParameterWrapper and set it to this property
    public class var mocker: MockingProtocol? {
        get {
            return API_mocker
        }
        set {
            API_mocker = newValue
        }
    }
    
    // // The optional delegate, that controls token refresh logic
    public class var tokenRefreshDelegate: TokenRefreshDelegate? {
        get {
            return API_tokenRefreshDelegate
        }
        set {
            API_tokenRefreshDelegate = newValue
        }
    }
    
    // MARK: Request creation from routers

    private class func createRequest(forRouter router: RouterProtocol) -> Request {
        
        // Make sure the operation queue is sequential
        API_operations.maxConcurrentOperationCount = 1
        
        // Get base URL
        var URL: NSURL?
        if router.urlEncode {
            URL = NSURL(string: router.baseURLString)?.URLByAppendingPathComponent(router.path)
        }
        else {
            URL = NSURL(string: router.path, relativeToURL: NSURL(string: router.baseURLString))
        }
        
        // Add relative path for specific case
        let mutableURLRequest = NSMutableURLRequest(URL: URL!)

        // Get method for this case
        mutableURLRequest.HTTPMethod = router.method.rawValue
        
        // Add optional header values
        for (headerKey, headerValue) in parameterMapper.headersForRouter(router) {
            mutableURLRequest.addValue(headerValue, forHTTPHeaderField: headerKey)
        }
        
        let parameters = parameterMapper.parametersForRouter(router)
        let encoding = router.encoding
        let requestTuple = encoding.encode(mutableURLRequest, parameters: parameters)
                
        return Alamofire.request(RequestWrapper(request: requestTuple.0))
    }
    
    // MARK: Request performing 
    
    private class func performRouter<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSHTTPURLResponse?, NSError?) -> ()) {
        
        // Do the actual request
        var request = API.createRequest(forRouter: router)
        
        request.responseObject { (_, response: NSHTTPURLResponse?, result: T?, error) in
            
            if let response = response, let tokenRefreshDelegate = self.tokenRefreshDelegate {
                
                if tokenRefreshDelegate.tokenRefreshIsIndicated(byResponse: response) {

                    // Create the token refresh operation
                    API_tokenRefreshOperation = TokenRefreshOperation(tokenRefreshDelegate: tokenRefreshDelegate, completion: { (refreshWasSuccessful) -> () in
                        
                        if refreshWasSuccessful == false {
                            // Refreshing failed, let the delegate now
                            tokenRefreshDelegate.tokenRefreshHasFailed()
                            // And cancel all
                            API_operations.cancelAllOperations()
                        }
                        
                        // Reset refresh operation
                        API_tokenRefreshOperation = nil
                    })
                    
                    // Enqueue the token refresh operation
                    API_operations.addOperation(API_tokenRefreshOperation!)
                    
                    // Enqueue the router, so that after the token refresh it is redone
                    self.enqueueRouter(router, complete: complete)
                    
                    // Do not call the complete block yet
                    return
                }
            }
            
            // No refresh needed, call completion block
            complete(result, response, error)
        }
        
    }
    
    // MARK: Request enqueueing
    
    private class func enqueueRouter<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSHTTPURLResponse?, NSError?) -> ()) {

        var blockOperation = NSBlockOperation(block: {
            self.performRouter(router, complete: complete)
        })
        
        if let tokenRefreshOperation = API_tokenRefreshOperation {
            blockOperation.addDependency(tokenRefreshOperation)
        }
        
        API_operations.addOperation(blockOperation)
    }
    
    // MARK: Private request method
    
    private class func completeRequest<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSHTTPURLResponse?, NSError?) -> ()) -> Request {

        // TODO: This request is not used !
        var request = API.createRequest(forRouter: router)
        
        if let mocker = API_mocker, let path = mocker.path(forRouter: router) {
            request.mockObject(forPath: path, withRouter: router, completionHandler: { (_, response: NSHTTPURLResponse?, result: T?, error) -> Void in
                complete(result, response, error)
            })
        }
        else {
            enqueueRouter(router, complete: complete)
        }
        
        return request
    }
    
    // MARK: Public request methods
    
    public class func tokenRefresh<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSHTTPURLResponse?, NSError?) -> ()) -> Request {
        
        var request = API.createRequest(forRouter: router)
        
        request.responseObject { (_, response: NSHTTPURLResponse?, result: T?, error) in
            // No refresh needed, call completion block
            
            complete(result, response, error)
        }
        
        return request
    }
    
    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    public class func request<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSError?) -> ()) -> Request {
        
        return API.completeRequest(router, complete: { (result, response, error) -> () in
            complete(result, error)
        })
    }
    
    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    // This version also gives the http response to the completion block
    public class func request<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSHTTPURLResponse?, NSError?) -> ()) -> Request {

        return API.completeRequest(router, complete: { (result, response, error) -> () in
            complete(result, response, error)
        })
    }
    
    // MARK: Helper method for requesting collections

    // We unfortunately have to use this extra call for collection parsing because Swift has problems with
    // generic types being used as generic types (A<T> as <T> in another class / method).
    public class func requestCollection<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (CollectionEntity<T>?, NSError?) -> ()) {
        
        API.request(router, complete: { (collectionResponse: CollectionResponse?, error) -> () in
            
            if let validCollection = collectionResponse {
                
                var localError: NSError?
                
                let result = CollectionEntity<T>(response: NSHTTPURLResponse(), collection: validCollection, error: &localError)
                
                if let existingError = localError {
                    complete(nil, localError)
                }
                else {
                    complete(result, nil)
                }
                
            }
            else {
                complete(nil, error)
            }
        })
    }
    
    // MARK: Methods to help with debugging
    
    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    public class func requestString(router: RouterProtocol, complete: (String?, NSHTTPURLResponse?, NSError?) -> ()) -> Request {
        
        var request = API.createRequest(forRouter: router)
        
        request.responseString(encoding: NSStringEncoding(NSUTF8StringEncoding)) { (internalRequest, response, responseString: String?, error) -> Void in
            complete(responseString, response, error)
        }
        
        return request
    }
    
}
