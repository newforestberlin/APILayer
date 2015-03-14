//
//  APIProtocols.swift
//  Officer_2
//
//  Created by Ricki Gregersen on 12/03/15.
//  Copyright (c) 2015 youandthegang.com. All rights reserved.
//

import Foundation
import Alamofire

// Protocol for API routers (this makes sure we use the same pattern always)
public protocol RouterProtocol {
    var method: Alamofire.Method { get }
    var path: String { get }
    var encoding: ParameterEncoding { get }
    var baseURLString: String { get }
}