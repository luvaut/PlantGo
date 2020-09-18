//
//  PlantData.swift
//  PlantGo
//
//  Created by 赵文赫 on 17/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit

class PlantData: NSObject, Decodable {

    var name: String?
    var scientificName: String?
    var yearDiscovered: Int?
    var family: String?
    var imgPath: String?
    
    private enum RootKeys: String, CodingKey {
        case name = "common_name"
        case scientificName = "scientific_name"
        case yearDiscovered = "year"
        case family
        case imgPath = "image_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        name = try? container.decode(String.self, forKey: .name)
        scientificName = try? container.decode(String.self, forKey: .scientificName)
        yearDiscovered = try? container.decode(Int.self, forKey: .yearDiscovered)
        family = try? container.decode(String.self, forKey: .family)
        imgPath = try? container.decode(String.self, forKey: .imgPath)
    }
    
    
}
