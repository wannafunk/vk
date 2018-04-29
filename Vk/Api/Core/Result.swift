//
//  Result.swift
//
//  Created by Andrey on 08.03.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

enum Result<T> {
    case value(T)
    case error(Error)
}
