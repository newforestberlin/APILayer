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

import Foundation

// Type for mapper methods that are used to map parameter items to types that are encodeable
typealias RequestParameterMapperMethod = (filterMethod: (AnyObject) -> Bool, constructMethod: (AnyObject) -> AnyObject)

// This class makes it easy to configure parameter construction in the router
public class RequestParameterMapper {
    
    // List of mapper methods used during parameterize()
    var methods: [RequestParameterMapperMethod]

    init(methods: [RequestParameterMapperMethod]) {
        self.methods = methods
    }
    
    // Performs mapping from input tuples to entries in the resulting dictionary that is then used for parameter encoding.
    func parameterize(tuples: (key: String, value: AnyObject)...) -> [String: AnyObject] {
        
        var result = [String: AnyObject]()

        // Iterate over all the mapper methods
        for method in methods {
            // Perform filter on the input tuples. The current mapper method filters out all the items 
            // that do fit, then performs mapping on these items.
            result = tuples.filter { (x) in method.filterMethod(x.value) }.reduce(result) { (resultRunning, item) in
                var mutableResultRunning = [String: AnyObject]()
                mutableResultRunning += result
                mutableResultRunning += [item.key : method.constructMethod(item.value)]
                return mutableResultRunning
            }
        }
        
        return result
    }
    
}