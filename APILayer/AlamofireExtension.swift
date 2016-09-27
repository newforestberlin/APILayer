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

// This code is based on the README of Alamofire (https://github.com/Alamofire/Alamofire).
// Thanks to Mattt Thompson for all the great stuff!

import Foundation
import Alamofire

// Errors for this API 
public enum APIResponseStatus: Error {
    case success
    case failedRequest(statusCode: Int)
    case unknownProblem
    case invalidTopLevelJSONType
    case missingKey(description: String)
    case invalidValue(description: String)
    case invalidMockResponse(path: String)
    case encodingError(description: String)
    case requestFailedWithResponse(statusCode: Int, response: URLResponse)
}

// Protocol for objects that can be constructed from parsed JSON. 
public protocol MappableObject {
    init(map: Map)
}

extension Alamofire.DataRequest {
    
    // MARK: Parsing method
    
    
    fileprivate func callCompletionAfterJSONParsing(_ value: Any, router: RouterProtocol, response: DataResponse<Any>,completionHandler: (_ request: URLRequest?, _ response: HTTPURLResponse?, _ result: MappableObject?, _ status: APIResponseStatus) -> Void) {
        
        switch value {
        case let dict as [String: AnyObject]:
            // Top level type is dictionary
            
            let map = Map(representation: dict as AnyObject)
            let object = router.result(forMap: map)
            
            if let object = object , map.error == nil {
                // Call completion handler wiht result
                completionHandler(response.request, response.response, object, .success)
            } else {
                if let error = map.error {
                    // Call completion handler with error result
                    completionHandler(response.request, response.response, nil, error)
                }
                else {
                    // Call completion handler with error result
                    completionHandler(response.request, response.response, nil, APIResponseStatus.unknownProblem)
                }
            }
            
        case let array as [AnyObject]:
            // Top level type is array
            
            var resultArray = [Any]()
            
            for itemDict in array {
                
                let itemMap = Map(representation: itemDict)
                let object = router.result(forMap: itemMap)
                
                if let object = object , itemMap.error == nil {
                    resultArray.append(object)
                }
            }
            
            if resultArray.count == array.count {
                
                // Construct collection entity to wrap the array
                let collection = CollectionEntity(map: Map(representation: [String: AnyObject]() as AnyObject))
                collection.items.append(contentsOf: resultArray)
                
                // Call completion handler wiht result
                completionHandler(response.request, response.response, collection, .success)
            } else {
                // Call completion handler with error result
                completionHandler(response.request, response.response, nil, APIResponseStatus.unknownProblem)
            }
            
        default:
            
            // Call completion handler with error result
            completionHandler(response.request, response.response, nil, APIResponseStatus.invalidTopLevelJSONType)
        }
        
    }
    
    public func handleJSONCompletion(_ router: RouterProtocol, response: DataResponse<Any>, completionHandler: (_ request: URLRequest?, _ response: HTTPURLResponse?, _ result: MappableObject?, _ status: APIResponseStatus) -> Void) {
        
        switch response.result {
        case .success(let value):
            
            // Valid JSON! Does not mean that the JSON contains valid content.
            
            // Check status for success
            if let urlResponse = response.response , urlResponse.statusCode < 200 || urlResponse.statusCode >= 300 {
                // Request failed (we do not care about redirects, just do not do that on your API. Return error but also the JSON object, might be useful for debugging.
                let error = APIResponseStatus.requestFailedWithResponse(statusCode: urlResponse.statusCode, response: urlResponse)
                
                // If the response is a dictionary we try to parse it
                if let dict = value as? [String: AnyObject] {

                    let map = Map(representation: dict as AnyObject)
                    let object = router.failureResult(forMap: map)
                    
                    // If we could parse something, pass that error object
                    if let object = object , map.error == nil {
                        completionHandler(response.request, urlResponse, object, APIResponseStatus.failedRequest(statusCode: urlResponse.statusCode))
                        return
                    }
                }
                
                completionHandler(response.request, urlResponse, nil, APIResponseStatus.failedRequest(statusCode: urlResponse.statusCode))
                return
            }
            
            // Try to construct object from JSON structure
            callCompletionAfterJSONParsing(value, router: router, response: response, completionHandler: completionHandler)
            
        case .failure(let error):
            // No valid JSON.
            
            // But maybe the status code is valid, and we got no JSON Body.
            if let urlResponse = response.response , urlResponse.statusCode >= 200 || urlResponse.statusCode < 300 {
                // Status code is valid, so try to create response object from empty dict 
                // because the client might expect that.
                let emptyDictionary = [String:String]()
                callCompletionAfterJSONParsing(emptyDictionary, router: router, response: response, completionHandler: completionHandler)
            } else {
                // Let router know that a request failed (in case ui wants to visualize that)
                router.requestFailed()
                
                let apiError = APIResponseStatus.invalidValue(description: error.localizedDescription)
                completionHandler(response.request, response.response, nil, apiError)
            }
        }
    }
    
    public func responseObject(_ router: RouterProtocol, completionHandler: @escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ result: MappableObject?, _ status: APIResponseStatus) -> Void) -> Self {
        
        
//        return responseString { response in
//                print("Success: \(response.result.isSuccess)")
//                print("Response String: \(response.result.value)")
//        }
//
//        return responseString(completionHandler: { response in
//            self.handleJSONCompletion(router, response: response, completionHandler: completionHandler)
//        })
        
        return responseJSON(completionHandler: { response in
            self.handleJSONCompletion(router, response: response, completionHandler: completionHandler)
        })        
    }
    
    public func mockObject(forPath path: String, withRouter router: RouterProtocol, completionHandler: (MappableObject?, APIResponseStatus) -> Void) -> Self {
        
        if let mockData = NSData(contentsOfFile: path) {
            
            // Load JSON from mock response file
            do {
                
                let jsonObject: Any = try JSONSerialization.jsonObject(with: mockData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                
                // Try to construct the object from the JSON structure
                
                
                switch jsonObject {
                case let dict as [String: AnyObject]:
                    // Top level type is dictionary
                    
                    let map = Map(representation: dict as AnyObject)
                    let object = router.result(forMap: map)
                    
                    if let object = object , map.error == nil {
                        // Call completion handler wiht result
                        completionHandler(object, .success)
                    } else {
                        if let error = map.error {
                            // Call completion handler with error result
                            completionHandler(nil, error)
                        }
                        else {
                            // Call completion handler with error result
                            completionHandler(nil, APIResponseStatus.unknownProblem)
                        }
                    }
                    
                case let array as [AnyObject]:
                    // Top level type is array
                    
                    var resultArray = [Any]()
                    
                    for itemDict in array {
                        let itemMap = Map(representation: itemDict)
                        let object = router.result(forMap: itemMap)
                        
                        if let object = object , itemMap.error == nil {
                            resultArray.append(object)
                        }
                    }
                    
                    if resultArray.count == array.count {
                        
                        // Construct collection entity to wrap the array
                        let collection = CollectionEntity(map: Map(representation: [String: AnyObject]() as AnyObject))
                        collection.items.append(contentsOf: resultArray)
                        
                        // Call completion handler wiht result
                        completionHandler(collection, .success)
                    } else {
                        // Call completion handler with error result
                        completionHandler(nil, APIResponseStatus.unknownProblem)
                    }
                    
                default:
                    
                    // Call completion handler with error result
                    completionHandler(nil, APIResponseStatus.invalidTopLevelJSONType)
                }

                
//                let map = Map(representation: jsonObject)
//                let object = router.result(forMap: map)
//                
//                if let error = map.error {
//                    
//                    completionHandler(nil, error)
//                    
//                } else {
//                    
//                    completionHandler(object, .Success)
//                }
            }
            catch {
                
                let apiError = APIResponseStatus.invalidMockResponse(path: path)
                completionHandler(nil, apiError)
            }            
        }
        
        return self
    }

    
}
