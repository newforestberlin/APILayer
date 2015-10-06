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
extension Float: Defaultable {}
extension Double: Defaultable {}
extension Bool: Defaultable {}
//extension Optional: Defaultable {}

public class ParameterMapper {        
    
    public var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    // This key is used in CollectionResponse to get the wrapped item array.
    public var collectionResponseItemsKey = "items"
    
    // This makes the constructor available to the public. Otherwise subclasses can't get initialized
    public init() {
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
    
    // MARK: Value extraction
  
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> T? {
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        return nil
    }
    
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> [T]? {
        
        if let value = representation.valueForKeyPath(key) as? [T] {
            return value
        }
        
        return nil
    }

    public func value<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject, key: String) -> T? {
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                var error: ErrorType?
                let entity = T(representation: validDict, error: &error)
                return error == nil ? entity : nil
            }
        }
        
        return nil
    }

    public func value<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject, key: String) -> [T]? {
        
        if let validArray = representation as? [AnyObject] {
            
            var result = [T]()
            
            for candidateItem in validArray {
                if let validDict = candidateItem as? [String: AnyObject] {
                    
                    var localError: ErrorType?
                    let entity = T(representation: validDict, error: &localError)
                    
                    // If deserialization of the entity failed, we ignore it
                    if localError == nil {
                        result.append(entity)
                    }
                }
            }
            
            return result
        }
        
        return nil
    }
    
    public func value(fromRepresentation representation: AnyObject, key: String) -> NSDate? {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = dateFormatter.dateFromString(value) {
                return date
            }
        }
        
        return nil
    }
    
    
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, inout error: ErrorType?) -> T {
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        error = ResponseObjectDeserializationError.MissingKey(description: "Could not extract value for key \(key). Key is missing.")
        
        return T()
    }
    
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, inout error: ErrorType?) -> [T] {
        if let value = representation.valueForKeyPath(key) as? [T] {
            return value
        }
        
        error = ResponseObjectDeserializationError.MissingKey(description: "Could not extract array for key \(key). Key is missing or type is wrong.")

        return []
    }
    
    public func value<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject, key: String, inout error: ErrorType?) -> T {
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                var localError: ErrorType?
                let entity = T(representation: validDict, error: &localError)
                
                if let localError = localError {
                    error = localError
                }
                
                return entity
                
            } else {
                error = ResponseObjectDeserializationError.InvalidValue(description: "Could not parse entity for key '\(key)'. Value is not a dictionary.")
            }
        }
        else {
            error = ResponseObjectDeserializationError.MissingKey(description: "Could not parse entity for key '\(key)'. Key is missing.")
        }
        
        // Return some object (we do not want to throw, otherwise "let" properties would be a problem in response entities)
        var dummyError: ErrorType?
        return T(representation: [:], error: &dummyError)
    }
    
    public func value<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject, key: String, inout error: ErrorType?) -> [T] {
        
        if let validObject: AnyObject = representation.valueForKey(key) {
            
            let validArray: [T]? = entityArray(fromRepresentation: validObject)
            if let validArray = validArray{
                return validArray
            }
            else {
                error = ResponseObjectDeserializationError.InvalidValue(description: "Could not parse entity array for key '\(key)'. Value is invalid.")
            }
            
        }
        
        error = ResponseObjectDeserializationError.MissingKey(description: "Could not parse entity array for key '\(key)'. Key is missing.")
        
        return []
    }
    
    public func value(fromRepresentation representation: AnyObject, key: String, inout error: ErrorType?) -> NSDate {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = dateFormatter.dateFromString(value) {
                return date
            }
        }
        
        error = ResponseObjectDeserializationError.MissingKey(description: "Could not parse date for key '\(key)'. Key is missing or format is wrong.")
        
        return NSDate()
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: Entity parsing
    
    public func entity<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject, key: String) -> T? {
        
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                var error: ErrorType?
                let entity = T(representation: validDict, error: &error)
                return error == nil ? entity : nil
            }
        }
        
        return nil
    }

    public func entity<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject, key: String, inout error: ErrorType?) -> T {
        
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                var localError: ErrorType?
                let entity = T(representation: validDict, error: &localError)
                
                if let localError = localError {
                    error = localError
                }
                
                return entity
                
            } else {
                error = ResponseObjectDeserializationError.InvalidValue(description: "Could not parse entity for key '\(key)'. Value is not a dictionary.")
            }
        }
        else {
            error = ResponseObjectDeserializationError.MissingKey(description: "Could not parse entity for key '\(key)'. Key is missing.")
        }
        
        // Return some object (we do not want to throw, otherwise "let" properties would be a problem in response entities)
        var dummyError: ErrorType?
        return T(representation: [:], error: &dummyError)
    }

    // MARK: Entity array parsing
    
    private func entityArray<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject) -> [T]? {
        
        if let validArray = representation as? [AnyObject] {
            
            var result = [T]()

            for candidateItem in validArray {
                if let validDict = candidateItem as? [String: AnyObject] {
                    
                    var localError: ErrorType?
                    let entity = T(representation: validDict, error: &localError)
                    
                    // If deserialization of the entity failed, we ignore it
                    if localError == nil {
                        result.append(entity)
                    }           
                }
            }
            
            return result
        }
        
        return nil
    }
    
    
    private func entityArray<T: ResponseObjectSerializable>(fromRepresentation representation: AnyObject, key: String, inout error: ErrorType?) -> [T] {
        
        if let validObject: AnyObject = representation.valueForKey(key) {
            
            let validArray: [T]? = entityArray(fromRepresentation: validObject)
            if let validArray = validArray{
                return validArray
            }
            else {
                error = ResponseObjectDeserializationError.InvalidValue(description: "Could not parse entity array for key '\(key)'. Value is invalid.")
            }
            
        }
        
        error = ResponseObjectDeserializationError.MissingKey(description: "Could not parse entity array for key '\(key)'. Key is missing.")
        
        return []
    }
    
//    public func entityArray<T: ResponseObjectSerializable>(representation: AnyObject, error: UnsafeMutablePointer<NSError?>) -> [T] throws {
//        let result: [T]? = entityArray(representation)
//        
//        if result == nil {
//            error.memory = NSError(domain: "ParameterMapper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Key for entity array was missing"])
//        }
//        
//        return result ?? [T]()
//    }
    
//    public func entityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String, error: UnsafeMutablePointer<NSError?>) -> [T] {
//        
//        let result: [T]? = entityArray(response, representation: representation, key: key)
//        
//        if result == nil {
//            error.memory = NSError(domain: "Mapper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Key for entity array was missing"])
//        }
//        
//        return result ?? [T]()
//    }
    
    // Swift compiler sometimes picks the wrong overload of the method, so this helps with that
    
//    public func optionalEntityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject) -> [T]? {
//        return entityArray(response, representation: representation)
//    }
//    
//    public func optionalEntityArray<T: ResponseObjectSerializable>(response: NSHTTPURLResponse, representation: AnyObject, key: String) -> [T]? {
//        return entityArray(response, representation: representation, key: key)
//    }
    
}