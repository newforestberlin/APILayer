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

// MARK : required protocols and extensions for generic to implement T() as an initializer
public protocol Defaultable {init()}
extension Int: Defaultable {}
extension String: Defaultable {}
extension NSDate: Defaultable {}
extension Float: Defaultable {}
extension Double: Defaultable {}
extension Bool: Defaultable {}
extension Optional: Defaultable {}

public class ParameterMapper {        
    
    public var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    // This key is used in CollectionResponse to get the wrapped item array.
    public var collectionResponseItemsKey = "items"
    
    // This makes the constructor available to the public. Otherwise subclasses can't get initialized
    public init() {
    }
    
    // MARK: General purpose value parsing
    
    public func valueFromRepresentation<T: Defaultable>(representation: AnyObject, key: String, error: UnsafeMutablePointer<NSError?>) -> T {
        
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        let errorDescription = "Could not extract value for key \(key). Key is missing."
        error.memory = NSError(domain: "APILayer.ParameterMapper.\(__FUNCTION__)", code: 0x1, userInfo: [NSLocalizedDescriptionKey: errorDescription, NSLocalizedFailureReasonErrorKey: representation])
        
        return T()
    }
    
    public func valueFromRepresentation<T: Defaultable>(representation: AnyObject, key: String) -> T? {
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        return nil
    }
    
    // MARK: Date parsing
    
    public func dateFromRepresentation(representation: AnyObject, key: String) -> NSDate? {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = dateFormatter.dateFromString(value) {
                return date
            }
            print("Invalid 'dateString'!!")
        }
        return nil
    }
    
    public func dateFromRepresentation(representation: AnyObject, key: String, error: UnsafeMutablePointer<NSError?>) -> NSDate {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = dateFormatter.dateFromString(value) {
                return date
            }
            
            let errorDescription = "Could not parse date for key '\(key)'. Date formatter might not recognize format."
            error.memory = NSError(domain: "APILayer.ParameterMapper.\(__FUNCTION__)", code: 0x1, userInfo: [NSLocalizedDescriptionKey: errorDescription, NSLocalizedFailureReasonErrorKey: representation])
            
            return NSDate()
            
        }

        let errorDescription = "Could not extract value for key '\(key)'. Key is missing."
        error.memory = NSError(domain: "APILayer.ParameterMapper.\(__FUNCTION__)", code: 0x1, userInfo: [NSLocalizedDescriptionKey: errorDescription, NSLocalizedFailureReasonErrorKey: representation])
        
        return NSDate()
    }
    
    // MARK: Array parsing

    public func arrayFromRepresentation(representation: AnyObject, key: String) -> [String]? {
        if let value = representation.valueForKeyPath(key) as? [String] {
            return value
        }
        
        return nil
    }
    
    public func arrayFromRepresentation(representation: AnyObject, key: String, error: UnsafeMutablePointer<NSError?>) -> [String] {
        if let value = representation.valueForKeyPath(key) as? [String] {
            return value
        }
        
        let errorDescription = "Could not extract value for key \(key). Key is missing."
        error.memory = NSError(domain: "APILayer.ParameterMapper.\(__FUNCTION__)", code: 0x1, userInfo: [NSLocalizedDescriptionKey: errorDescription, NSLocalizedFailureReasonErrorKey: representation])
        
        return []
    }
    
    public func arrayFromRepresentation(representation: AnyObject, key: String) -> [Int]? {
        if let value = representation.valueForKeyPath(key) as? [Int] {
            return value
        }
        
        return nil
    }
    
    // MARK: Date formatting

    public func stringFromDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: Parameters for routers
    
    public func parametersForRouter(router: RouterProtocol) -> [String : AnyObject] {
        print("You need to implement the method parametersForRouter() in your ParameterMapper subclass in order to have parameters in your requests")
        return [:]
    }
    
    // MARK: Headers for routers
    
    public func headersForRouter(router: RouterProtocol) -> [String : String] {
        return [:]
    }
    
    // MARK: Entity parsing
    
    public func entity<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String) -> T? {
        
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                var error: NSError?
                let entity = T(response: response, representation: validDict, error: &error)
                
                if error == nil {
                    return entity
                }
            }
        }
        
        return nil
    }

    // MARK: Entity array parsing
    
    public func entityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject) -> [T]? {
        
        var result = [T]()
        
        if let validArray = representation as? [AnyObject] {
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
    
    
    public func entityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String) -> [T]? {
        
        if let validObject: AnyObject = representation.valueForKey(key) {
            return entityArray(response, representation: validObject)
        }
        
        return nil
    }
    
    public func entityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, error: UnsafeMutablePointer<NSError?>) -> [T] {
        let result: [T]? = entityArray(response, representation: representation)
        
        if result == nil {
            error.memory = NSError(domain: "ParameterMapper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Key for entity array was missing"])
        }
        
        return result ?? [T]()
    }
        
    public func entityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String, error: UnsafeMutablePointer<NSError?>) -> [T] {
        
        let result: [T]? = entityArray(response, representation: representation, key: key)
        
        if result == nil {
            error.memory = NSError(domain: "Mapper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Key for entity array was missing"])
        }
        
        return result ?? [T]()
    }
    
    // Swift compiler sometimes picks the wrong overload of the method, so this helps with that
    
    public func optionalEntityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject) -> [T]? {
        return entityArray(response, representation: representation)
    }
    
    public func optionalEntityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String) -> [T]? {
        return entityArray(response, representation: representation, key: key)
    }
    
}