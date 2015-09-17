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

class DemoEntity: ResponseObjectSerializable {
    
    let keys = (firstName: "firstname", lastName: "lastname", age: "age")
    
    let firstName: String
    let lastName: String
    let age: Int
    
    required init(representation: AnyObject) throws {
        
        let mapper = API.parameterMapper
        var error: ErrorType?
        
        firstName = mapper.value(fromRepresentation: representation, key: keys.firstName, error: &error)
        lastName = mapper.value(fromRepresentation: representation, key: keys.lastName, error: &error)
        age = mapper.value(fromRepresentation: representation, key: keys.age, error: &error)
        
        if let error = error {
            throw error
        }
    }
    
    required init() {
        firstName = ""
        lastName = ""
        age = 0
    }
    
}

