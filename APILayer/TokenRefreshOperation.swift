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

open class SwiftOperation: Operation {
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _executing: Bool = false
    override open var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _finished: Bool = false;
    override open var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    func completeOperation () {
        isExecuting = true
        isFinished = true
    }
    
    override open func start()
    {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        main()
    }
    
    final override public func main() {
        execute()
    }
    
    func execute() {
    }

}

open class TokenRefreshOperation: SwiftOperation {

    let tokenRefreshDelegate: TokenRefreshDelegate
    var completion: (_ refreshWasSuccessful: Bool) -> ()
    
    init(tokenRefreshDelegate: TokenRefreshDelegate, completion: @escaping (_ refreshWasSuccessful: Bool) -> ()) {
        self.tokenRefreshDelegate = tokenRefreshDelegate
        self.completion = completion
        super.init()
    }
    
    override func execute() {
        
        tokenRefreshDelegate.tokenRefresh { (refreshWasSuccessful) -> () in
            self.completion(refreshWasSuccessful)
            self.completeOperation()
        }
    }
    
}
