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

// Protocol for API routers (this makes sure we use the same pattern always)
public protocol RouterProtocol {
    var method: Alamofire.Method { get }
    var path: String { get }
}

// This class functions as the main interface to the API layer.
public class API {

    // Performs request with the specified Router. Completion block is called in case of success / failure later on.
    public class func request<T: ResponseObjectSerializable>(router: URLRequestConvertible, complete: (T?, NSError?) -> ()) -> Request? {

        var request = Alamofire.request(router)
        request.responseObject { (_, _, result: T?, error) in
            complete(result, error)
        }

        return request
    }

    // MARK: Value extraction methods, that return dummy values in case of failure (valid flag is set to false in this case)
    // These methods do not return optionals because we do not want optionals in our entity classes all over the place.
    // If parsing the fields does fail, the entity is just marked as invalid by setting valid to false. This makes
    // the responseObject method return nil for the entity.

    class func getNSDateFromRepresentation(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> NSDate {
        if let value = representation.valueForKeyPath(key) as? NSDate {
            return value
        }

        // In case of missing key, set valid flag to false to mark parsing as unsuccessful
        valid.memory = false

        return NSDate()
    }

    class func getIntFromRepresentation(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> Int {
        if let value = representation.valueForKeyPath(key) as? Int {
            return value
        }

        // In case of missing key, set valid flag to false to mark parsing as unsuccessful
        valid.memory = false

        return 0
    }

    class func getStringFromRepresentation(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> String {
        if let value = representation.valueForKeyPath(key) as? String {
            return value
        }

        // In case of missing key, set valid flag to false to mark parsing as unsuccessful
        valid.memory = false

        return ""
    }

    class func getBoolFromRepresentation(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> Bool {
        if let value = representation.valueForKeyPath(key) as? Bool {
            return value
        }

        // In case of missing key, set valid flag to false to mark parsing as unsuccessful
        valid.memory = false

        return false
    }

    class func getDoubleFromRepresentation(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> Double {
        if let value = representation.valueForKeyPath(key) as? Double {
            return value
        }

        // In case of missing key, set valid flag to false to mark parsing as unsuccessful
        valid.memory = false

        return 0.0
    }

    class func getFloatFromRepresentation(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> Float {
        if let value = representation.valueForKeyPath(key) as? Float {
            return value
        }

        // In case of missing key, set valid flag to false to mark parsing as unsuccessful
        valid.memory = false

        return 0.0
    }

}
