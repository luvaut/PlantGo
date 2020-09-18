//
//  DatabaseProtocol.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    case exhibitions
    case plants
    
}
protocol DatabaseListener: AnyObject {
 var listenerType: ListenerType {get set}
 func onExhibitionListChange(change: DatabaseChange, exhibitions: [Exhibition])
 func onPlantListChange(change: DatabaseChange, plants: [Plant])
}
protocol DatabaseProtocol: AnyObject {

    func cleanUp()
    func addExhibition(name: String, desc: String, lat: Double, long: Double, iconPath: String) -> Exhibition
    func addPlant(name: String, scientificName: String, yearDiscovered: Int16, family: String, imgPath: String) -> Plant
    func addPlant(plantData: PlantData) -> Plant
    func addPlantToExhibition(plant: Plant, to exhibition: Exhibition) -> Bool
    func deleteExhibition(exhibition: Exhibition)
    func deletePlant(plant: Plant)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
