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

import UIKit
import Alamofire

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image: UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let image = image {
            picker.dismissViewControllerAnimated(true) { () -> Void in
                self.upload(profileImage: image)
            }
        } else {
            picker.dismissViewControllerAnimated(true) { () -> Void in
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
        }
    }
    
    func upload(profileImage image: UIImage) {
        
        print("Uploading...")
        API.request(Router.UploadImage(image: image)) { (result: Result<ImageUpload>) -> () in
            switch result {
            case .Success(let imageUpload):
                print("Uploaded image has now the id \(imageUpload.imageId)")
            case .Failure(_, let error):
                print("Uploading the image failed!")
                print(error)
            }
        }
      
    }
    
}


class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doRequestAction(sender: AnyObject) {
        
        // Set this to true to test image upload. You will also have to point your router to your backend.
        let testImageUpload = false
        
        if testImageUpload {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            presentViewController(picker, animated: true, completion: nil)
        } else {
            
            API.requestCollection(Router.GetCollection) { (result: Result<CollectionEntity<DemoItem>>) -> () in
                let missing = "<missing>"
                
                if let collection = result.value {
                    var report = ""
                    
                    for item in collection.items {
                        report = report + "itemId=\(item.itemId ?? missing), title=\(item.title ?? missing) ac=\(item.awesomeCount ?? 0)\n"
                        if let subItem = item.subItem {
                            print("SUBITEM!")
                        }
                    }
                    
                    self.textView.text = report
                }
                else {
                    self.textView.text = "Could not find any items!"
                }
                
                API.request(Router.GetEntity(id: "123")) { (result: Result<DemoEntity>) -> () in
                    
                    switch result {
                    case .Success(let demoEntity):
                        print(demoEntity.firstName)
                    case .Failure(let data, let error):
                        print("Failed")
                    }
                }
            }
        }
    }

}

