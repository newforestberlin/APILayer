# APILayer

Sources for API layers we use in iOS apps, based on Alamofire (https://github.com/Alamofire/Alamofire).

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Usage 

Most elegant way to use this is with Carthage (https://github.com/Carthage/Carthage): 

1. Add a Cartfile to your projects root folder with these two lines:

        github "Alamofire/Alamofire" >= 1.1
        github "youandthegang/APILayer" >= 1.0.1

2. Call 'carthage update' on the console on that folder. This fetches the newest tagged versions of the two frameworks and builds them, placing the resulting frameworks in Carthage/Build/iOS
3. Drag the two frameworks from Carthage/Build/iOS into your Xcode project, at the targets 'Linked Frameworks and Libraries'
4. Add a 'Copy Files' phase to your targets 'Build Phases'. Set 'Destination' to 'Frameworks'. Add both frameworks to the file list.

## Demo project

To run the demo project you first have to build Alamofire with 'carthage update'. 




