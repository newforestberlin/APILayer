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

// Type for items returned by demo "API" response
public class DemoItem: ResponseObjectSerializable {

    // Keys for serializing JSON
    class var keys: (itemId :String, title :String, awesomeCount: String) {
        return ("id", "title", "awesome_count")
    }
    
    // Properties of the entity. Optional values can be nil in the JSON, non-optional values must be present or the request will fail
    public let itemId: String
    public let title: String
    public let awesomeCount: Int?

    // Get property values from parsed JSON
    public required init(response: NSHTTPURLResponse, representation: AnyObject, valid: UnsafeMutablePointer<Bool>) {
        // Thanks to the extraction methods we do not need optionals. If something can't get extracted 
        // because key is missing or type is invalid, the valid flag is set to false and a default values is returned.
        let mapper = API.parameterMapper
        itemId = mapper.valueFromRepresentation(representation, key: DemoItem.keys.itemId, valid: valid)
        title = mapper.valueFromRepresentation(representation, key: DemoItem.keys.title, valid: valid)
        //Notice 'valid' flag is not passed here - this means the return value is optional
        awesomeCount = mapper.valueFromRepresentation(representation, key: DemoItem.keys.awesomeCount)
    }
    
}