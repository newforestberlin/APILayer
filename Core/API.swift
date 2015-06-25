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

// This flag indicates if we are currently refreshing the auth token
private var API_currentlyRefreshingAuthToken = false

// This queue is used to delay requests when a token refresh is needed. The requests are then performed after the refresh is done.
private var API_waitingOperations = NSOperationQueue()

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
    
    // MARK: Private request methods

    private class func createRequest(forRouter router: RouterProtocol) -> Request {
        
        // Make sure the operation queue is sequential
        API_waitingOperations.maxConcurrentOperationCount = 1
        
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
    
    private class func completeRequest<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSHTTPURLResponse?, NSError?) -> ()) -> Request {

        var request = API.createRequest(forRouter: router)
        
        if let mocker = API_mocker, let path = mocker.path(forRouter: router) {
            request.mockObject(forPath: path, withRouter: router, completionHandler: { (_, response: NSHTTPURLResponse?, result: T?, error) -> Void in
                complete(result, response, error)
            })
        }
        else {
            request.responseObject { (_, response: NSHTTPURLResponse?, result: T?, error) in
                complete(result, response, error)
            }
        }
        
        return request
    }
    
    // MARK: Public request methods
    
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
