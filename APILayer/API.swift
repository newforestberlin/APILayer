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

enum APILayerError: Error {
    case requestFailedWithJSONValue(statusCode: Int, jsonValue: AnyObject)
}

// Setting the delegate is optional. If set, it can control how the API handles auth token refreshing
public protocol TokenRefreshDelegate {
    
    // For each response the delegate is asked if it implies that token refresh is neeed. Could check for HTTP status for example.
    func tokenRefreshIsIndicated(byResponse response: HTTPURLResponse) -> Bool
    
    // Must refresh the token and call the completion block on failure or succcess. Should do a refresh request.
    // If refresh was successful, the waiting requests are performed in order and everything goes on. If however
    // refreshing failed, all waiting requests are cancelled and the delegates tokenRefreshHasFailed() method is called,
    // so that the app can react to that (log out for example).
    func tokenRefresh(_ completion: (_ refreshWasSuccessful: Bool) -> ())
    
    // Called if token refresh has failed. In this case all waiting requests are removed and the app should react to that.
    func tokenRefreshHasFailed()
}

// Wrapper to make URLRequest conform to URLRequestConvertible
class RequestWrapper: URLRequestConvertible {
    let request: URLRequest
    init(request: URLRequest) {
        self.request = request
    }
    
    func asURLRequest() throws -> URLRequest {
        return request
    }
    
}

// This class functions as the main interface to the API layer.
open class API {
    
    // Custom manager, for example if you need security policy exceptions when using unsigned SSL certificates on the backend
    open static var customManager: Alamofire.SessionManager?
    
    // Mapper
    open static var mapper = Mapper()
    
    // If this one is set it might return mock paths for router cases, in which case the API does use mock data from local filesystem
    open static var mocker: MockProtocol?
    
    // The optional delegate, that controls token refresh logic
    open static var tokenRefreshDelegate: TokenRefreshDelegate?

    // This queue is used to delay requests when a token refresh is needed. The requests are then performed after the refresh is done.
    fileprivate static var operations = OperationQueue()
    
    // If this is set, we are currently refreshing the token
    fileprivate static var tokenRefreshOperation: Operation?
    
    // MARK: Request creation from routers

    fileprivate class func createRequest(forRouter router: RouterProtocol) -> DataRequest? {
        
        // Make sure the operation queue is sequential
        API.operations.maxConcurrentOperationCount = 1
        
        // Get base URL
        let baseURL = URL(string: router.path, relativeTo: URL(string: router.baseURLString))
        
        // Create request
        var mutableURLRequest = URLRequest(url: baseURL!)

        // Get method for this case
        mutableURLRequest.httpMethod = router.method.rawValue
        
        // Add optional header values
        for (headerKey, headerValue) in API.mapper.headersForRouter(router) {
            mutableURLRequest.addValue(headerValue, forHTTPHeaderField: headerKey)
        }
        
        let parameters = API.mapper.parametersForRouter(router)
        let encoding = router.encoding
        
        /// - returns: The encoded request.
        //public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest
        
        do {
            let encodedRequest = try encoding.encode(mutableURLRequest, with: parameters)

            if let customManager = API.customManager {
                return customManager.request(RequestWrapper(request: encodedRequest))
            } else {
                return Alamofire.request(RequestWrapper(request: encodedRequest))
            }
        }
        catch {
            return nil
        }
        
        return nil
    }
    
    // MARK: Request performing 
    
    internal class func performRouter(_ router: RouterProtocol, complete: @escaping (URLRequest?, HTTPURLResponse?, MappableObject?, APIResponseStatus) -> ()) {
        
        // Do the actual request
        guard let request = API.createRequest(forRouter: router) else {
            complete(nil, nil, nil, APIResponseStatus.unknownProblem)
            return
        }

        if let uploadData = router.uploadData {
            // Data uploads are using a multipart request
            
            // TODO: Needs token refresh logic!
            
            if let urlRequest = request.request {
                Alamofire.upload(multipartFormData: { (formData: MultipartFormData) -> Void in
                    formData.append(uploadData.data, withName: uploadData.name, fileName: uploadData.fileName, mimeType: uploadData.mimeType)
                    },
                                 
                    usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
                    
                    with: urlRequest, encodingCompletion: { (encodingResult) -> Void in
                        
                        switch encodingResult {
                        case .success(let uploadRequest, _, _):
                            
                            uploadRequest.responseJSON(completionHandler: { response in
                                uploadRequest.handleJSONCompletion(router, response: response, completionHandler: complete)
                            })
                            
                        case .failure(let encodingError):
                            // TODO: Need better description here
                            complete(nil, nil, nil, APIResponseStatus.encodingError(description: "Failed"))
                        }
                })
                
            }
            
        } else {
            
            // Get the response object
            request.responseObject(router) { (request: URLRequest?, response: HTTPURLResponse?, result: MappableObject?, status: APIResponseStatus) in
                
                if let response = response, let tokenRefreshDelegate = self.tokenRefreshDelegate {
                    
                    if tokenRefreshDelegate.tokenRefreshIsIndicated(byResponse: response) {
                        
                        // Create the token refresh operation
                        API.tokenRefreshOperation = TokenRefreshOperation(tokenRefreshDelegate: tokenRefreshDelegate, completion: { (refreshWasSuccessful) -> () in
                            
                            if refreshWasSuccessful == false {
                                // Refreshing failed, let the delegate know
                                tokenRefreshDelegate.tokenRefreshHasFailed()
                                // And cancel all
                                API.operations.cancelAllOperations()
                            }
                            
                            // Reset refresh operation
                            API.tokenRefreshOperation = nil
                        })
                        
                        // Enqueue the token refresh operation
                        API.operations.addOperation(API.tokenRefreshOperation!)
                        
                        // Enqueue the router, so that after the token refresh it is redone
                        self.enqueueRouter(router, complete: complete)
                        
                        // Do not call the complete block yet
                        return
                    }
                }
                
                // No refresh needed, status is in the success area.
                complete(request, response, result, status)
            }
        }
    }
    
    // MARK: Request enqueueing
    
    fileprivate class func enqueueRouter(_ router: RouterProtocol, complete: @escaping (URLRequest?, HTTPURLResponse?, _ result: MappableObject?, _ status: APIResponseStatus) -> ()) {
        
        var routerOperation: Operation?
        
        if router.blockedOperation {
            routerOperation = BlockedRouterOperation(router: router, completion: complete)
        } else {
            routerOperation = BlockOperation(block: {
                self.performRouter(router, complete: complete)
            })
        }
        
        if let tokenRefreshOperation = API.tokenRefreshOperation {
            routerOperation?.addDependency(tokenRefreshOperation)
        }

        if let routerOperation = routerOperation {
            API.operations.addOperation(routerOperation)
        }
    }
    
    // MARK: Private request method. If there is a mocker, looks there. If not existing, enqueues the router.
    
    fileprivate class func completeRequest(_ router: RouterProtocol, complete: @escaping (URLRequest?, HTTPURLResponse?, MappableObject?, APIResponseStatus) -> ()) {
        
        if let mocker = API.mocker, let path = mocker.path(forRouter: router) {
            
            // Do the actual request
            guard let request = API.createRequest(forRouter: router) else {
                complete(nil, nil, nil, APIResponseStatus.unknownProblem)
                return
            }
            
            request.mockObject(forPath: path, withRouter: router, completionHandler: { (result, status) -> Void in
                complete(nil, nil, result, status)
            })
        }
        else {
            enqueueRouter(router, complete: complete)
        }
    }
    
    // MARK: Public request methods
    
    open class func tokenRefresh(_ router: RouterProtocol, complete: @escaping (_ result: MappableObject?, _ status: APIResponseStatus) -> ()) {

        // This method must be used by the actual token refresh logic in the app. 
        // It does not use the operation queue used for other requests.
        // Very important, because this method does NOT enqueue the request. While token 
        // refresh is working all enqueued requests are waiting for the token refresh to finish
        // by calling the completion(refreshWasSuccessful: Bool).
        
        guard let request = API.createRequest(forRouter: router) else {
            complete(nil, APIResponseStatus.unknownProblem)
            return
        }
        
        request.responseObject(router) { (request, response, result, status) -> Void in
            complete(result, status)
        }
        
    }
    
    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    open class func request(_ router: RouterProtocol, complete: @escaping (_ result: MappableObject?, _ status: APIResponseStatus) -> ()) {
        
        API.completeRequest(router) { (urlRequest, urlResponse, result: MappableObject?, status: APIResponseStatus) -> () in
            complete(result, status)
        }
    }

    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    // This version also gives the http response to the completion block
    open class func request(_ router: RouterProtocol, complete: @escaping (_ result: MappableObject?, _ status: APIResponseStatus, _ urlResponse: HTTPURLResponse?) -> ()) {

        API.completeRequest(router) { (urlRequest, urlResponse, result, status) -> () in
            complete(result, status, urlResponse)
        }

    }
    
    // MARK: Methods to help with debugging
    

    open class func requestString(_ router: RouterProtocol, complete: @escaping (String?, Error?) -> ()) {
        
        complete(nil, nil)

//        let request = API.createRequest(forRouter: router)
//        request.responseString { response in
//            print("Response String: \(response.result.value)")
//            complete(response.result.value, nil)
//        }
    }
    
    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    open class func requestStatus(_ router: RouterProtocol, complete: @escaping (Int?, Error?) -> ()) {
        
        guard let request = API.createRequest(forRouter: router) else {
            complete(nil, APIResponseStatus.unknownProblem)
            return
        }
        
//        request.responseString { response in
//            print("Response String: \(response.result.value)")
//        }

        request.response { (response) in
            let statusCode = response.response?.statusCode
            complete(statusCode, response.error)
        }
//
    }
    
}
