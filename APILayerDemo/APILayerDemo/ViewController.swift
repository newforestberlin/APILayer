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
        
        let tags = ["you & the gang", "mobile product consulting", "concepts", "ux & ui design", "prototypes", "architecture", "ios", "swift", "scala", "akka"]
        
        API.request(Router.DemoResponse(firstName: "Ole", lastName: "Sprause", tags: tags), complete: { (items: DemoItems?, error) -> () in
            
            let missing = "<missing>"
            
            if let validItems = items {
                var report = ""
                
                for item in validItems.items {
                    report = report + "itemId=\(item.itemId ?? missing), title=\(item.title ?? missing) ac=\(item.awesomeCount ?? 0)\n"
                }
                
                self.textView.text = report
            }
            else {
                self.textView.text = "Could not find any items! Error says \(error?.localizedDescription ?? missing)"
            }
        })
        
    }

}

