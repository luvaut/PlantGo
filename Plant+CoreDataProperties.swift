//
//  Plant+CoreDataProperties.swift
//  PlantGo
//
//  Created by 赵文赫 on 6/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//
//

import Foundation
import CoreData


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var family: String?
    @NSManaged public var imgPath: String?
    @NSManaged public var name: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var yearDiscovered: Int16
    @NSManaged public var plantExhibition: NSSet?

}

// MARK: Generated accessors for plantExhibition
extension Plant {

    @objc(addPlantExhibitionObject:)
    @NSManaged public func addToPlantExhibition(_ value: Exhibition)

    @objc(removePlantExhibitionObject:)
    @NSManaged public func removeFromPlantExhibition(_ value: Exhibition)

    @objc(addPlantExhibition:)
    @NSManaged public func addToPlantExhibition(_ values: NSSet)

    @objc(removePlantExhibition:)
    @NSManaged public func removeFromPlantExhibition(_ values: NSSet)

}
