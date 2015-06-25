/// Correct implementation of "NSOperation" subclass that does post the
/// appropriate "isFinished" and "isExecuting" notification
///
/// Because this posts "isFinished" and "isExecuting", this will succeed in
/// recognizing that the operation finished. Thus, if you use dependencies or
/// if you are relying up "maxConcurrentOperationCount", this will
/// work properly.
///
/// Please compare this to BadAsynchronousOperation

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