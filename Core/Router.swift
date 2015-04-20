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

// Implement all API specific endpoints, with parameters, URLs and all that is needed
public enum Router: RouterProtocol {
    
    // Cases for all the different API calls
    case DemoGETRequest(param: String)
    case DemoPOSTRequest(param: String)
    case DemoPUTRequest(param: String)
    case DemoDELETERequest(param: String)
    
    // Base URL of the API
    public var baseURLString: String {
        return "http://pixelogik.de/"
    }

    // Methods for all the different calls
    public var method: Alamofire.Method {
        switch self {
        case .DemoGETRequest:
            return .GET
        case .DemoPOSTRequest:
            return .POST
        case .DemoPUTRequest:
            return .PUT
        case .DemoDELETERequest:
            return .DELETE
        }
    }
    
    // Relative paths for all the different calls
    public var path: String {
        switch self {
        case .DemoGETRequest:
            return "static/apilayer-test.json"
        case .DemoPOSTRequest:
            return "not/implemented"
        case .DemoPUTRequest:
            return "not/implemented"
        case .DemoDELETERequest:
            return "not/implemented"
        }
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        case .DemoGETRequest:
            return ParameterEncoding.URL
        case .DemoPOSTRequest:
            return ParameterEncoding.JSON
        case .DemoPUTRequest:
            return ParameterEncoding.JSON
        case .DemoDELETERequest:
            return ParameterEncoding.JSON
        }
    }
}