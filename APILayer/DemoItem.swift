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

    // Properties of the entity. We make these optional so that parsing never fails
    public let itemId: String?
    public let title: String?
    public let awesomeCount: Int?
    
    // Keys for extracting from the parsed JSON
    let keys = (itemId: "id", title: "title", awesomeCount: "awesome_count")

    // Get property values from parsed JSON
    public required init(response: NSHTTPURLResponse, representation: AnyObject, valid: UnsafeMutablePointer<Bool>) {
        itemId = representation.valueForKeyPath(keys.itemId) as? String
        title = representation.valueForKeyPath(keys.title) as? String
        awesomeCount = representation.valueForKeyPath(keys.awesomeCount) as? Int
        
        // Mark as invalid
        // valid.memory = false
    }
    
}