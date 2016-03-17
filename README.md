# APILayer

The APILayer framework sits on top of Alamofire (https://github.com/Alamofire/Alamofire) and provides a high level abstraction for API layers that are often needed in iOS applications to communicate with backends / APIs. 

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

APILayer has changed a lot in the last months. An updated explanation comes soon...

We changed how mapping works. We decided that we prefer to support non-optional properties to the cost of having no free to-json mechanism. Other frameworks allow you to specify one mapping for to-json and from-json to the cost of not supporting non-optionals. To us non-optionals are much more helpful because it makes sure that if a response could be parsed, you dont have to check for nils all over the place when using it. On the other hand only 30% of our API model entities need to be send back to the API, so adding manually toDict() methods for these is worth having non-optionals. 

Having non-optionals works because we have a Defaultable protocol that all basic types and model entities support. In the entity constructor each property is assigned with a value. 

The JSON parsing component is now independent on all the networking stuff, so we might move that into a dedicated framework soon. 

Example:

    import APILayer
    import Alamofire

    class User: MappableObject {
        
        let id: Int
        let firstName: String
        let lastName: String

        let phoneNumber: String?
        let email: String?

        let friends: [User]?
        
        required init(map: Map) {            
            id = map.value("id")
            firstName = map.value("first_name")
            lastName = map.value("last_name")
            phoneNumber = map.value("phone_number")
            email = map.value("email")
            friends = map.value("friends")
        }

    }

## Getting the framework

Most elegant way to get the framework is with Carthage (https://github.com/Carthage/Carthage): 

1. Add a Cartfile to your projects root folder with this one line:

        github "youandthegang/APILayer" >= 2.1

2. Call 'carthage update' on the console on that folder. This fetches the newest tagged versions of APILayer and Alamofire and builds them, placing the resulting frameworks in Carthage/Build/iOS

3. Drag the two frameworks (APILayer and Alamofire) from Carthage/Build/iOS into your Xcode project, at the targets 'Linked Frameworks and Libraries'

4. Add a 'Copy Files' phase to your targets 'Build Phases'. Set 'Destination' to 'Frameworks'. Add both frameworks to the file list.


