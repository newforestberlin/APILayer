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

public class SwiftOperation: NSOperation {
    
    override public var asynchronous: Bool {
        return true
    }
    
    private var _executing: Bool = false
    override public var executing: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValueForKey("isExecuting")
                _executing = newValue
                didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override public var finished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValueForKey("isFinished")
                _finished = newValue
                didChangeValueForKey("isFinished")
            }
        }
    }
    
    func completeOperation () {
        executing = true
        finished = true
    }
    
    override public func start()
    {
        if cancelled {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }
    
    final override public func main() {
        execute()
    }
    
    func execute() {
    }

}

public class TokenRefreshOperation: SwiftOperation {

    let tokenRefreshDelegate: TokenRefreshDelegate
    var completion: (refreshWasSuccessful: Bool) -> ()
    
    init(tokenRefreshDelegate: TokenRefreshDelegate, completion: (refreshWasSuccessful: Bool) -> ()) {
        self.tokenRefreshDelegate = tokenRefreshDelegate
        self.completion = completion
        super.init()
    }
    
    override func execute() {
        
        tokenRefreshDelegate.tokenRefresh { (refreshWasSuccessful) -> () in
            self.completion(refreshWasSuccessful: refreshWasSuccessful)
            self.completeOperation()
        }
    }
    
}