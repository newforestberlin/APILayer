# APILayer

Sources for API layers we use in iOS apps, based on Alamofire (https://github.com/Alamofire/Alamofire).

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## What is this

The APILayer framework sits on top of Alamofire and consists of four main classes, 

- API: Main interface to the API layer, that is performing requests and has a configurable parameter mapper
- ParameterMapper: 


## Usage 

Most elegant way to use this is with Carthage (https://github.com/Carthage/Carthage): 

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


## Demo project

To run the demo project you first have to build Alamofire with 'carthage update'. 




