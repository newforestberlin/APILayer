//
//  MockingProtocol.swift
//  APILayerDemo
//
//  Created by Olee on 30.04.15.
//  Copyright (c) 2015 you & the gang. All rights reserved.
//

import Foundation

public protocol MockingProtocol {
    func path(forRouter router: RouterProtocol) -> String?
}


