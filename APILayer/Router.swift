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
public enum Router: RouterProtocol, URLRequestConvertible {
    
    // Cases for all the different API calls
    case DemoResponse(firstName: String, lastName: String, tags: [String])
    
    // Parameter mapper, initialized with the API specific parameter mappers (static because shared)
    private static var parameterMapper = RequestParameterMapper(
        methods: [
            
            // Mapper method for string values
            (
                filterMethod: {(item: AnyObject) -> Bool in return (item as? String) != nil},
                constructMethod: {(item: AnyObject) -> AnyObject in return item as String }
            ),
            
            // Mapper method for arrays of strings (turns them into joined string)
            (
                filterMethod: {(item: AnyObject) -> Bool in return (item as? [String]) != nil},
                constructMethod: {(item: AnyObject) -> AnyObject in return ",".join(item as [String]) }
            )
        ]
    )
    
    // Base URL of the API (static because shared)
    private static func baseURLString() -> String { return "http://pixelogik.de/" }
    
    // Methods for all the different calls
    public var method: Alamofire.Method {
        switch self {
        case .DemoResponse:
            return .GET
        }
    }
    
    // Relative paths for all the different calls
    public var path: String {
        switch self {
        case .DemoResponse:
            return "static/apilayer-test.json"
        }
    }
    
    // Property implementation according to URLRequestConvertible
    public var URLRequest: NSURLRequest {
        
        // Get base URL
        let URL = NSURL(string: Router.baseURLString())
        
        // Add relative path for specific case
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        
        // Get method for this case
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // Create parameter dictionary
        var params = [String:AnyObject]()
        
        // Keys of request parameters (all fake, demo API does not use this)
        let paramKeys = (
            firstName: "first_name",
            lastName: "last_name",
            tags: "tags"
        )

        // Depending on enum case return specific request
        switch self {
        
        case DemoResponse(let firstName, let lastName, let tags):
            
            // Add mapped parameters to params dictionary.
            params += Router.parameterMapper.parameterize(
                (paramKeys.firstName, firstName),
                (paramKeys.lastName, lastName),
                (paramKeys.tags, tags)
            )

            // The parameterMapper must guarantee that all objets put into the params dictionary are encodeable by this method.
            return ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0

        default:
            return mutableURLRequest
        }
    }
    
    
}