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

class Mapper: ParameterMapper {

    override func parametersForRouter(router: RouterProtocol) -> [String : AnyObject] {
        if let route = router as? Router {
            
            switch route {
            case .DemoGETRequest(let param):
                return [DemoItem.keys.title : "random title sent to backend"]
            case .DemoPOSTRequest(let param):
                return [:]
            case .DemoPUTRequest(let param):
                return [:]
            case .DemoDELETERequest(let param):
                return [:]
            }
        }
        
        return [:]
    }
    
    // MARK: Entity array parsing
    
    class func entityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String) -> [T]? {
        
        if let validObject: AnyObject = representation.valueForKey(key) {
            var result = [T]()
            
            if let validArray = validObject as? [AnyObject] {
                for candidateItem in validArray {
                    if let validDict = candidateItem as? [String: AnyObject] {
                        
                        var error: NSError?
                        let entity = T(response: response, representation: validDict, error: &error)
                        
                        if error == nil {
                            // Parsing entity worked
                            result.append(entity)
                        }
                    }
                }
            }
            
            return result
        }
        
        return nil
    }
    
    class func entityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String, error: UnsafeMutablePointer<NSError?>) -> [T] {
        let result: [T]? = Mapper.entityArray(response, representation: representation, key: key)
        
        if result == nil {
            error.memory = NSError(domain: "Mapper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Key for entity array was missing"])
        }
        
        return result ?? [T]()
    }
    
}