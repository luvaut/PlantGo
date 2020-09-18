//
//  Exhibition+CoreDataProperties.swift
//  PlantGo
//
//  Created by 赵文赫 on 6/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//
//

import Foundation
import CoreData


extension Exhibition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exhibition> {
        return NSFetchRequest<Exhibition>(entityName: "Exhibition")
    }

    @NSManaged public var desc: String?
    @NSManaged public var iconPath: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var name: String?
    @NSManaged public var exbihitionPlant: NSSet?

}

// MARK: Generated accessors for exbihitionPlant
extension Exhibition {

    @objc(addExbihitionPlantObject:)
    @NSManaged public func addToExbihitionPlant(_ value: Plant)

    @objc(removeExbihitionPlantObject:)
    @NSManaged public func removeFromExbihitionPlant(_ value: Plant)

    @objc(addExbihitionPlant:)
    @NSManaged public func addToExbihitionPlant(_ values: NSSet)

    @objc(removeExbihitionPlant:)
    @NSManaged public func removeFromExbihitionPlant(_ values: NSSet)

}
