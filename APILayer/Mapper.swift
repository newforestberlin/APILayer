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

infix operator <-

open class Map {
    
    open var error: APIResponseStatus?

    open var representation: AnyObject
    
    public init(representation: AnyObject) {
        self.representation = representation
    }
    
    open func value<T: Defaultable>(_ key: String) -> T {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    open func value<T: Defaultable>(_ key: String) -> T? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    open func value<T: Defaultable>(_ key: String) -> [T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    open func value<T: Defaultable>(_ key: String) -> [T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    open func value<T: MappableObject>(_ key: String) -> T {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    open func value<T: MappableObject>(_ key: String) -> T? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    open func value<T: MappableObject>(_ key: String) -> [T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }
    
    open func value<T: MappableObject>(_ key: String) -> [T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    open func value(_ key: String) -> Date {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }

    open func value(_ key: String) -> Date? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }
    
    open func value(_ key: String) -> [String: AnyObject]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    open func value(_ key: String) -> [String: AnyObject] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }

    open func value(_ key: String, formatter: DateFormatter) -> Date {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error, customFormatter: formatter)
    }
    
    open func value(_ key: String, formatter: DateFormatter) -> Date? {
        return API.mapper.value(fromRepresentation: representation, key: key, customFormatter: formatter)
    }
    
    open func value<T: MappableObject>(_ key: String) -> [String: T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    open func value<T: MappableObject>(_ key: String) -> [String: T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    open func value<T: Defaultable>(_ key: String) -> [String: T] {
        return API.mapper.value(fromRepresentation: representation, key: key, error: &error)
    }
    
    open func value<T: Defaultable>(_ key: String) -> [String: T]? {
        return API.mapper.value(fromRepresentation: representation, key: key)
    }

    static func map<T: MappableObject>(fromRepresentation representation: AnyObject) -> T? {
        let map = Map(representation: representation)
        let entity = T(map: map)
        return map.error == nil ? nil : entity
    }
    
}


open class Mapper {
    
    open var dateFormatter: DateFormatter = DateFormatter()
    
    // This key is used in CollectionResponse to get the wrapped item array.
    open var collectionResponseItemsKey = "items"
    
    // This makes the constructor available to the public. Otherwise subclasses can't get initialized
    public init() {
    }
    
    // MARK: Date formatting
    
    open func stringFromDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // MARK: Parameters for routers
    
    open func parametersForRouter(_ router: RouterProtocol) -> [String : Any]? {
        print("You need to implement the method parametersForRouter() in your Mapper subclass in order to have parameters in your requests")
        return nil
    }
    
    // MARK: Headers for routers
    
    open func headersForRouter(_ router: RouterProtocol) -> [String : String] {
        return [:]
    }
    
    // MARK: Single value extraction
  
    open func value(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> Date {
        if let value = representation.value(forKeyPath: key) as? String {
            if let date = dateFormatter.date(from: value) {
                return date
            }
        }
        
        error = APIResponseStatus.missingKey(description: "Could not parse date for key '\(key)'. Key is missing or format is wrong.")
        
        return Date()
    }
    
    open func value(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?, customFormatter: DateFormatter) -> Date {
        if let value = representation.value(forKeyPath: key) as? String {
            if let date = customFormatter.date(from: value) {
                return date
            }
        }
        
        error = APIResponseStatus.missingKey(description: "Could not parse date for key '\(key)'. Key is missing or format is wrong.")
        
        return Date()
    }

    open func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> T? {
        if let value = representation.value(forKeyPath: key) as? T {
            return value
        }
        
        return nil
    }
    
    open func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String) -> T? {
        
        if let candidateObject: Any = representation.value(forKey: key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                let map = Map(representation: validDict as AnyObject)
                let entity = T(map: map)
                
                return map.error == nil ? entity : nil
            }
        }
        
        return nil
    }
    
    open func value(fromRepresentation representation: AnyObject, key: String) -> [String: AnyObject]? {
        if let value = representation.value(forKeyPath: key) as? [String: AnyObject] {
            return value
        }
        
        return nil
    }
    
    open func value(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> [String: AnyObject] {
        if let value = representation.value(forKeyPath: key) as? [String: AnyObject] {
            return value
        }
        
        error = APIResponseStatus.missingKey(description: "Could not extract value for key \(key). Key is missing.")
        
        return [:]
    }
    
    open func value(fromRepresentation representation: AnyObject, key: String) -> Date? {
        if let value = representation.value(forKeyPath: key) as? String {
            if let date = dateFormatter.date(from: value) {
                return date
            }
        }
        
        return nil
    }
    
    open func value(fromRepresentation representation: AnyObject, key: String, customFormatter: DateFormatter) -> Date? {
        if let value = representation.value(forKeyPath: key) as? String {
            if let date = customFormatter.date(from: value) {
                return date
            }
        }
        
        return nil
    }
    
    open func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> T {
        if let value = representation.value(forKeyPath: key) as? T {
            return value
        }
        
        error = APIResponseStatus.missingKey(description: "Could not extract value for key \(key). Key is missing.")
        
        return T()
    }
    
    open func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> T {
        if let candidateObject: Any = representation.value(forKey: key) {
            if let validDict = candidateObject as? [String: AnyObject] {
                
                let map = Map(representation: validDict as AnyObject)
                let entity = T(map: map)
                
                //                var localError: APIResponseStatus?
                //                let entity = T(representation: validDict, error: &localError)
                
                if let localError = map.error {
                    error = localError
                }
                
                return entity
                
            } else {
                error = APIResponseStatus.invalidValue(description: "Could not parse entity for key '\(key)'. Value is not a dictionary.")
            }
        }
        else {
            error = APIResponseStatus.missingKey(description: "Could not parse entity for key '\(key)'. Key is missing.")
        }
        
        // Return some object (we do not want to throw, otherwise "let" properties would be a problem in response entities)
        let map = Map(representation: [:] as AnyObject)
        return T(map: map)
        
        //        var dummyError: APIResponseStatus?
        //        return T(representation: [:], error: &dummyError)
    }

    // MARK: Array value extraction
    
    open func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> [T] {
        
        let validObject = representation.value(forKey: key)
        
        if validObject != nil {
            
            let validAnyObjectArray = validObject as AnyObject
            
            let validArray: [T]? = entityArray(fromRepresentation: validAnyObjectArray)
            if let validArray = validArray{
                return validArray
            }
            else {
                error = APIResponseStatus.invalidValue(description: "Could not parse entity array for key '\(key)'. Value is invalid.")
            }
        }
        
        error = APIResponseStatus.missingKey(description: "Could not parse entity array for key '\(key)'. Key is missing.")
        
        return []
    }

    open func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> [T]? {
        
        if let value = representation.value(forKeyPath: key) as? [T] {
            return value
        }
        
        return nil
    }

    open func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String) -> [T]? {
     
        if let candidateObject: Any = representation.value(forKey: key), let validAnyCandidateObject = candidateObject as? AnyObject {
            if let validArray = validAnyCandidateObject as? [AnyObject] {
                
                var result = [T]()
                
                for candidateItem in validArray {
                    if let validDict = candidateItem as? [String: AnyObject] {
                        
                        let map = Map(representation: validDict as AnyObject)
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
    
    open func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> [T] {
        if let value = representation.value(forKeyPath: key) as? [T] {
            return value
        }
        
        error = APIResponseStatus.missingKey(description: "Could not extract array for key \(key). Key is missing or type is wrong.")
        
        return []
    }

    // MARK: Dictionary value extraction

    open func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String) -> [String: T]? {
        if let candidateObject: Any = representation.value(forKey: key), let validAnyCandidateObject = candidateObject as? AnyObject  {
            if let validDict = validAnyCandidateObject as? [String: AnyObject] {
                
                var result = [String: T]()
                
                for (key, value) in validDict {
                    if let entityDict = value as? [String: AnyObject] {
                        let map = Map(representation: entityDict as AnyObject)
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
    
    open func value<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> [String: T] {
        if let candidateObject: Any = representation.value(forKey: key), let validAnyCandidateObject = candidateObject as? AnyObject {
            if let validDict = validAnyCandidateObject as? [String: AnyObject] {
                
                var result = [String: T]()
                
                for (key, value) in validDict {
                    if let entityDict = value as? [String: AnyObject] {
                        let map = Map(representation: entityDict as AnyObject)
                        let entity = T(map: map)
                        
                        if map.error == nil {
                            result[key] = entity
                        }
                    }
                }
                
                return result
            } else {
                error = APIResponseStatus.missingKey(description: "Value for key \(key) is not a dictionary.")
                return [:]
            }
        }
        
        error = APIResponseStatus.missingKey(description: "Could not extract value for key \(key). Key is missing.")
        return [:]
    }
    
    open func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> [String: T] {
        if let value = representation.value(forKeyPath: key) as? [String: T] {
            return value
        }
        
        error = APIResponseStatus.missingKey(description: "Could not extract array for key \(key). Key is missing or type is wrong.")
        return [:]
    }
    
    open func value<T: Defaultable>(fromRepresentation representation: AnyObject, key: String) -> [String: T]? {
        if let value = representation.value(forKeyPath: key) as? [String: T] {
            return value
        }
        
        return nil
    }
    
    // MARK: Internal entity array parsing
    
    fileprivate func entityArray<T: MappableObject>(fromRepresentation representation: AnyObject) -> [T]? {
        
        if let validArray = representation as? [AnyObject] {
            
            var result = [T]()

            for candidateItem in validArray {
                if let validDict = candidateItem as? [String: AnyObject] {
                    
                    let map = Map(representation: validDict as AnyObject)
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
    
    
    fileprivate func entityArray<T: MappableObject>(fromRepresentation representation: AnyObject, key: String, error: inout APIResponseStatus?) -> [T] {
        
        if let validObject: Any = representation.value(forKey: key), let validAnyObject = validObject as? AnyObject {
            
            let validArray: [T]? = entityArray(fromRepresentation: validAnyObject)
            if let validArray = validArray{
                return validArray
            }
            else {
                error = APIResponseStatus.invalidValue(description: "Could not parse entity array for key '\(key)'. Value is invalid.")
            }
            
        }
        
        error = APIResponseStatus.missingKey(description: "Could not parse entity array for key '\(key)'. Key is missing.")
        
        return []
    }
    
}
