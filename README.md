# APILayer

The APILayer framework sits on top of Alamofire (https://github.com/Alamofire/Alamofire) and provides a high level abstraction for API layers that are often needed in iOS applications to communicate with backends / APIs. 

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

APILayer has changed a lot in the last months. An updated explanation comes soon...

## Getting the framework

Most elegant way to get the framework is with Carthage (https://github.com/Carthage/Carthage): 

1. Add a Cartfile to your projects root folder with this one line:

        github "youandthegang/APILayer" >= 2.1

2. Call 'carthage update' on the console on that folder. This fetches the newest tagged versions of APILayer and Alamofire and builds them, placing the resulting frameworks in Carthage/Build/iOS
3. Drag the two frameworks (APILayer and Alamofire) from Carthage/Build/iOS into your Xcode project, at the targets 'Linked Frameworks and Libraries'
4. Add a 'Copy Files' phase to your targets 'Build Phases'. Set 'Destination' to 'Frameworks'. Add both frameworks to the file list.


## Demo project

To run the demo project you first have to build Alamofire with 'carthage update'. Then just open it and run. 




