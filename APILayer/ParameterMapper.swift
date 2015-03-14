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

// MARK : required protocols and extension for generic to implement T() as an initializer
public protocol Defaultable {init()}
extension Int: Defaultable {}
extension String: Defaultable {}
extension NSDate: Defaultable {}
extension Float: Defaultable {}
extension Double: Defaultable {}
extension Bool: Defaultable {}
extension Optional: Defaultable {}

public class ParameterMapper {
    
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    // MARK: Value extraction methods, that return dummy values in case of failure (valid flag is set to false in this case)
    // These methods do not return optionals because we do not want optionals in our entity classes all over the place.
    // If parsing the fields does fail, the entity is just marked as invalid by setting valid to false. This makes
    // the responseObject method return nil for the entity.
    
    // Function for populating a 'let' property. i.e. returns property or returns defualt property and sets 'valid' to false
    public func valueFromRepresentation<T: Defaultable>(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> T {
        
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        valid.memory = false
        
        return T()
    }
    
    // Function for populating a 'var' property. i.e. returns property or nil
    public func valueFromRepresentation<T: Defaultable>(representation: AnyObject, key: String) -> T? {
        if let value = representation.valueForKeyPath(key) as? T {
            return value
        }
        
        return nil
    }
    
    public func dateFromRepresentation(representation: AnyObject, key: String) -> NSDate? {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = dateFormatter.dateFromString(value) {
                return date
            }
            println("Invalid 'dateString'!!")
        }
        return nil
    }
    
    public func dateFromRepresentation(representation: AnyObject, key: String, valid: UnsafeMutablePointer<Bool>) -> NSDate {
        if let value = representation.valueForKeyPath(key) as? String {
            if let date = dateFormatter.dateFromString(value) {
                return date
            }
            println("Invalid 'dateString'!!")
        }
        valid.memory = false
        return NSDate()
    }
    
    public func stringFromDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    //
    func parametersForRouter(router: RouterProtocol) -> [String : AnyObject] {
        println("You need to implement this method in your ParameterMapper subclass")
        return [:]
    }
}