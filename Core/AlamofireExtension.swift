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

// Thrown by the parameter mapper if keys can't be found or values are invalid
enum ResponseObjectDeserializationError: ErrorType {
    case MissingKey(description: String)
    case InvalidValue(description: String)
}

// Protocol for objects that can be constructed from parsed JSON. 
// Might throw a ResponseObjectDeserializationError case when using 
// the parameter mapper to get values from the representation.
public protocol ResponseObjectSerializable {
    init(representation: AnyObject) throws
}

extension Alamofire.Request {
    
    // MARK: Parsing method
    
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: (request: NSURLRequest?, response: NSHTTPURLResponse?, result: Result<T>) -> Void) -> Self {
        
        return responseJSON(completionHandler: { (urlRequest, urlResponse, result) -> Void in
            
            switch result {
            case .Success(let value):
                
                // We do have a valid JSON structure
                
                do {
                    
                    // Try to construct object from JSON structure
                    let object = try T(representation: value)
                    completionHandler(request: urlRequest, response: urlResponse, result: Result<T>.Success(object))
                    
                } catch let thrownError {
                    
                    // Call completion handler with error result
                    completionHandler(request: urlRequest, response: urlResponse, result: Result<T>.Failure(nil, thrownError))
                    
                }
            
            case .Failure(let data, let error):
                
                completionHandler(request: urlRequest, response: urlResponse, result: Result<T>.Failure(data, error))
                
            }
        })        
    }
    
    public func mockObject<T: ResponseObjectSerializable>(forPath path: String, withRouter router: RouterProtocol, completionHandler: (Result<T>) -> Void) -> Self {
        
        if let mockData = NSData(contentsOfFile: path) {
            
            do {
                // Load JSON from mock response file
                let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(mockData, options: NSJSONReadingOptions.AllowFragments)
                
                // Try to construct the object from the JSON structure
                let object = try T(representation: jsonObject)
                completionHandler(Result<T>.Success(object))
                
            } catch let thrownError {
                
                completionHandler(Result<T>.Failure(nil, thrownError))
                
            }
        }
        
        return self
    }

    
}