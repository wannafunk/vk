//
//  Empty.swift
//
//  Created by Andrey on 25.05.16.
//  Copyright © 2016 All rights reserved.
//

import Foundation
import ObjectMapper

class Empty : Mappable {
    required init?(map: Map) {}
    func mapping(map: Map){}
}
