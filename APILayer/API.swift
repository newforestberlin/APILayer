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
    
    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    public class func request<T: ResponseObjectSerializable>(router: RouterProtocol, complete: (T?, NSError?) -> ()) -> Request? {
        
        // Get base URL
        let URL = NSURL(string: router.baseURLString)
        
        // Add relative path for specific case
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(router.path))
        
        // Get method for this case
        mutableURLRequest.HTTPMethod = router.method.rawValue

        // Add optional header values
        for (headerKey, headerValue) in parameterMapper.headersForRouter(router) {
            mutableURLRequest.addValue(headerValue, forHTTPHeaderField: headerKey)
        }
        
        let parameters = parameterMapper.parametersForRouter(router)
        let encoding = router.encoding
        let requestTuple = encoding.encode(mutableURLRequest, parameters: parameters)
        
        var request = Alamofire.request(RequestWrapper(request: requestTuple.0))
        request.responseObject { (_, _, result: T?, error) in
            complete(result, error)
        }
        
        return request
    }
}
