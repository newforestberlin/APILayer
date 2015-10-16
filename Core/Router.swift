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

// This code is based on the README of Alamofire (https://github.com/Alamofire/Alamofire).
// Thanks to Mattt Thompson for all the great stuff!

import Foundation
import Alamofire
import UIKit

// Implement all API specific endpoints, with parameters, URLs and all that is needed
enum Router: RouterProtocol {

    // Cases for all the different API calls
    case GetCollection
    case GetEntity(id: String)
    
    // This case does not work with the pixelogik.de endpoints. It is just here to show how image uploading works.
    case UploadImage(image: UIImage)
    
    // Base URL of the API
    var baseURLString: String {
        return "http://pixelogik.de/"
    }
    
    // I use this to test image uploading with a local backend
    // var baseURLString: String { return "http://0.0.0.0:5000/" }

    var uploadData: (data: NSData, name: String, fileName: String, mimeType: String)? {
        switch self {
        case .UploadImage(let image):
            if let imageData = UIImageJPEGRepresentation(image, 0.8) {
                return (data: imageData, name: "profileImage", fileName: "profileImage.jpg", mimeType: "image/jpeg")
            }
        default:
            ()
        }
        
        return nil
    }

    // Methods for all the different calls
    var method: Alamofire.Method {
        switch self {
        case .GetCollection, .GetEntity:
            return .GET
        case .UploadImage:
            return .POST
        }
    }
    
    // Relative paths for all the different calls
    var path: String {
        switch self {
        case .GetCollection:
            return "static/apilayer-demo-collection.json"
        case .GetEntity:
            return "static/apilayer-demo-entity.json"
        case .UploadImage:
            return "testImageUpload"
        }
    }
    
    var encoding: ParameterEncoding {
        return ParameterEncoding.URL
    }
}
