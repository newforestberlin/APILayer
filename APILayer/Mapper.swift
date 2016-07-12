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

infix operator <- {}

public class Map {
    
    public var error: APIResponseStatus?

    public var representation: AnyObject
    
    public init(representation: AnyObject) {
        self.representation = representation
    }
    
    public func value<T: Defaultable>(key: String) -> T {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    public func value<T: Defaultable>(key: String) -> T? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    public func value<T: Defaultable>(key: String) -> [T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    public func value<T: Defaultable>(key: String) -> [T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    public func value<T: MappableObject>(key: String) -> T {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    public func value<T: MappableObject>(key: String) -> T? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    public func value<T: MappableObject>(key: String) -> [T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }
    
    public func value<T: MappableObject>(key: String) -> [T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    public func value(key: String) -> NSDate {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }

    public func value(key: String) -> NSDate? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }
    
    public func value(key: String, formatter: NSDateFormatter) -> NSDate {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error, customFormatter: formatter)
    }
    
    public func value(key: String, formatter: NSDateFormatter) -> NSDate? {
        return API.mapper.value(fromRepresentation: representation, key: key, customFormatter: formatter)
    }
    
    public func value<T: MappableObject>(key: String) -> [String: T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    public func value<T: MappableObject>(key: String) -> [String: T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    public func value<T: Defaultable>(key: String) -> [String: T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    public func value<T: Defaultable>(key: String) -> [String: T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    static func map<T: MappableObject>(fromRepresentation representation: AnyObject) -> T? {
        let map = Map(representation: representation)
        let entity = T(map: map)
        return map.error == nil ? nil : entity
    }
    
}


public class Mapper {
    
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
    
    public func parametersForRouter(router: RouterProtocol) -> [String : AnyObject]? {
        print("You need to implement the method parametersForRouter() in your Mapper subclass in order to have parameters in your requests")
        return nil
    }
    
    // MARK: Headers for routers
    
    public func headersForRouter(router: RouterProtocol) -> [String : String] {
        return [:]
    }
    
    // MARK: Single value extraction
  
    public func value(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> NSDate {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = dateFormatter.dateFromString(value) {
                return date
            }
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not parse date for key '\(key)'. Key is missing or format is wrong.")
        
        return NSDate()
    }
    
    public func value(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?, customFormatter: NSDateFormatter) -> NSDate {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = customFormatter.dateFromString(value) {
                return date
            }
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not parse date for key '\(key)'. Key is missing or format is wrong.")
        
        return NSDate()
    }

    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> T? {
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        return nil
    }
    
    public func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String) -> T? {
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                let map = Map(representation: validDict)
                let entity = T(map: map)
                
                return map.error == nil ? entity : nil
            }
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
    
    public func value(fromRepresentation representation: AnyObject, key: String, customFormatter: NSDateFormatter) -> NSDate? {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = customFormatter.dateFromString(value) {
                return date
            }
        }
        
        return nil
    }
    
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> T {
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not extract value for key \(key). Key is missing.")
        
        return T()
    }
    
    public func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> T {
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                let map = Map(representation: validDict)
                let entity = T(map: map)
                
                //                var localError: APIResponseStatus?
                //                let entity = T(representation: validDict, error: &localError)
                
                if let localError = map.error {
                    error = localError
                }
                
                return entity
                
            } else {
                error = APIResponseStatus.InvalidValue(description: "Could not parse entity for key '\(key)'. Value is not a dictionary.")
            }
        }
        else {
            error = APIResponseStatus.MissingKey(description: "Could not parse entity for key '\(key)'. Key is missing.")
        }
        
        // Return some object (we do not want to throw, otherwise "let" properties would be a problem in response entities)
        let map = Map(representation: [:])
        return T(map: map)
        
        //        var dummyError: APIResponseStatus?
        //        return T(representation: [:], error: &dummyError)
    }

    // MARK: Array value extraction
    
    public func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> [T] {
        
        if let validObject: AnyObject = representation.valueForKey(key) {
            
            let validArray: [T]? = entityArray(fromRepresentation: validObject)
            if let validArray = validArray{
                return validArray
            }
            else {
                error = APIResponseStatus.InvalidValue(description: "Could not parse entity array for key '\(key)'. Value is invalid.")
            }
            
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not parse entity array for key '\(key)'. Key is missing.")
        
        return []
    }

    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> [T]? {
        
        if let value = representation.valueForKeyPath(key) as? [T] {
            return value
        }
        
        return nil
    }

    public func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String) -> [T]? {
     
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validArray = candidateObject as? [AnyObject] {
                
                var result = [T]()
                
                for candidateItem in validArray {
                    if let validDict = candidateItem as? [String: AnyObject] {
                        
                        let map = Map(representation: validDict)
                        let entity = T(map: map)
                        
                        // If deserialization of the entity failed, we ignore it
                        if map.error == nil {
                            result.append(entity)
                        }
                    }
                }
                
                return result
            }
        }
        
        return nil
    }
    
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> [T] {
        if let value = representation.valueForKeyPath(key) as? [T] {
            return value
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not extract array for key \(key). Key is missing or type is wrong.")
        
        return []
    }

    // MARK: Dictionary value extraction

    public func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String) -> [String: T]? {
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                var result = [String: T]()
                
                for (key, value) in validDict {
                    if let entityDict = value as? [String: AnyObject] {
                        let map = Map(representation: entityDict)
                        let entity = T(map: map)
                        
                        if map.error == nil {
                            result[key] = entity
                        }
                    }
                }
                
                return result
            }
        }
        
        return nil
    }
    
    public func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> [String: T] {
        if let candidateObject: AnyObject = representation.valueForKey(key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                var result = [String: T]()
                
                for (key, value) in validDict {
                    if let entityDict = value as? [String: AnyObject] {
                        let map = Map(representation: entityDict)
                        let entity = T(map: map)
                        
                        if map.error == nil {
                            result[key] = entity
                        }
                    }
                }
                
                return result
            } else {
                error = APIResponseStatus.MissingKey(description: "Value for key \(key) is not a dictionary.")
                return [:]
            }
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not extract value for key \(key). Key is missing.")
        return [:]
    }
    
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> [String: T] {
        if let value = representation.valueForKeyPath(key) as? [String: T] {
            return value
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not extract array for key \(key). Key is missing or type is wrong.")
        return [:]
    }
    
    public func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> [String: T]? {
        if let value = representation.valueForKeyPath(key) as? [String: T] {
            return value
        }
        
        return nil
    }
    
    // MARK: Internal entity array parsing
    
    private func entityArray<T: MappableObject>(fromRepresentation representation: AnyObject) -> [T]? {
        
        if let validArray = representation as? [AnyObject] {
            
            var result = [T]()

            for candidateItem in validArray {
                if let validDict = candidateItem as? [String: AnyObject] {
                    
                    let map = Map(representation: validDict)
                    let entity = T(map: map)
                    
                    // If deserialization of the entity failed, we ignore it
                    if map.error == nil {
                        result.append(entity)
                    }           
                }
            }
            
            return result
        }
        
        return nil
    }
    
    
    private func entityArray<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, inout error: APIResponseStatus?) -> [T] {
        
        if let validObject: AnyObject = representation.valueForKey(key) {
            
            let validArray: [T]? = entityArray(fromRepresentation: validObject)
            if let validArray = validArray{
                return validArray
            }
            else {
                error = APIResponseStatus.InvalidValue(description: "Could not parse entity array for key '\(key)'. Value is invalid.")
            }
            
        }
        
        error = APIResponseStatus.MissingKey(description: "Could not parse entity array for key '\(key)'. Key is missing.")
        
        return []
    }
    
}