# APILayer

The APILayer framework sits on top of Alamofire (https://github.com/Alamofire/Alamofire) and provides a high level abstraction for API layers that are often needed in iOS applications to communicate with backends / APIs. 

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

The framework consists of four main components:

- API: Main interface to the API layer, that is performing requests and has a configurable parameter mapper
- RouterProtocol: This protocol is an extension of the pattern used in the README of Alamofire.
- ParameterMapper: Generates request parameter dictionaries from router cases. Also maps response values to native types and vice versa. Has a configurable date formatter. 
- ResponseObjectSerializable: This protocol is an extension of the one used in the Alamofire examples. We added a NSError? inout variable to the constructor, so that the value extraction can invalidate a parsed model entity by specifying an error. This minimizes the usage of optionals in model entity classes. 

## Usage 

To implement your custom API layer you have to implement the RouterProtocol protocol, that is used by the API.request() method: 
     
        public protocol RouterProtocol {
                var method: Alamofire.Method { get }
                var path: String { get }
                var encoding: ParameterEncoding { get }
                var baseURLString: String { get }
        }

This allows very flexible implementation of the actual routing logic. We prefer the pattern used by the Alamofire README file, as an enum with one case for each API endpoint:

        public enum Router: RouterProtocol {
    
                case DemoGETRequest(param: String)
                case DemoPOSTRequest(param: String)
    
                public var baseURLString: String {
                        return "http://pixelogik.de/"
                }

                public var method: Alamofire.Method {
                        switch self {
                        case DemoGETRequest:
                                return .GET
                        case DemoPOSTRequest:
                                return .POST    
                        }
                }
    
                public var path: String {
                        switch self {
                        case .DemoGETRequest:
                                return "static/apilayer-test.json"
                        case DemoPOSTRequest:
                                return "not/implemented"
                        }
                }
    
                public var encoding: ParameterEncoding {
                        switch self {
                        case .DemoGETRequest:
                                return ParameterEncoding.URL
                        case DemoPOSTRequest:
                                return ParameterEncoding.JSON
                        }
                }

        }

Furthermore you have to implement the ResponseObjectSerializable protocol in your response class. This protocol specifies how response / model entities are constructed from the response data:

        public class DemoItem: ResponseObjectSerializable {

            class var keys: (itemId :String, title :String, awesomeCount: String) { return ("id", "title", "awesome_count") }
    
            // Properties of the entity. Optional values can be nil in the JSON, non-optional values must be present or the request will fail
            let itemId: String
            let title: String
            let awesomeCount: Int?

            // Get property values from parsed JSON
            required init(response: NSHTTPURLResponse, representation: AnyObject, error: UnsafeMutablePointer<NSError?>) {
                // Thanks to the extraction methods we do not need optionals. If something can't get extracted 
                // because key is missing or type is invalid, the error is set and a default value is returned.        
                itemId = API.parameterMapper.valueFromRepresentation(representation, key: DemoItem.keys.itemId, error: error)
                title = API.parameterMapper.valueFromRepresentation(representation, key: DemoItem.keys.title, error: error)
                // Notice 'error' parameter is not passed here - this means the return value is optional
                awesomeCount = API.parameterMapper.valueFromRepresentation(representation, key: DemoItem.keys.awesomeCount)
            }
    
        }

Then you can make API requests like this: 

        API.request(Router.DemoGETRequest(param: tag), complete: { (item: DemoItem?, error) -> () in            
            if let validItem = item {            
                // We have a valid item...
            }
        })

## Getting the framework

Most elegant way to get the framework is with Carthage (https://github.com/Carthage/Carthage): 

1. Add a Cartfile to your projects root folder with these two lines:

        github "Alamofire/Alamofire" >= 1.1
        github "youandthegang/APILayer" >= 1.0.1

2. Call 'carthage update' on the console on that folder. This fetches the newest tagged versions of the two frameworks and builds them, placing the resulting frameworks in Carthage/Build/iOS
3. Drag the two frameworks from Carthage/Build/iOS into your Xcode project, at the targets 'Linked Frameworks and Libraries'
4. Add a 'Copy Files' phase to your targets 'Build Phases'. Set 'Destination' to 'Frameworks'. Add both frameworks to the file list.

Import the APILayer framework in all the Swift files where you want to use it:

        import UIKit
        import APILayer

        class ViewController: UIViewController {

                override func viewDidLoad() {
                super.viewDidLoad()
                
                API.request(Router.DemoGETRequest(param: "myTag"), complete: { (items: DemoItems?, error) -> () in
            
                if let validItems = items {

        ...
        
Sometimes you also need types from Alamofire, in which case you also have to import that: 

        import Alamofire
        import APILayer

        // Implement all API specific endpoints, with parameters, URLs and all that is needed
        public enum Router: RouterProtocol {
    
                // Cases for all the different API calls
                case DemoGETRequest(param: String)

                // Methods for all the different calls, needs type from Alamofire
                public var method: Alamofire.Method {

        ...

## Demo project

To run the demo project you first have to build Alamofire with 'carthage update'. Then just open it and run. 




