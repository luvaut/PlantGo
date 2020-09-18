//
//  ExhibitionAnnotation.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit
import MapKit

class ExhibitionAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    var title: String?
    var subtitle: String?
    init(title: String, sub: String, lat: Double, long: Double) {
        self.title = title
        self.subtitle = sub
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
