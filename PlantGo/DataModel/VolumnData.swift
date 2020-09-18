//
//  VolumnData.swift
//  PlantGo
//
//  Created by 赵文赫 on 17/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit

class VolumnData: NSObject, Decodable {

    var meta: [String: Int]?
    var links: [String: String]?
    var plants: [PlantData]?
    
    
    private enum CodingKeys: String, CodingKey {
        case meta
        case links
        case plants = "data"
    }
}
