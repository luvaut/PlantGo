//
//  CoreDataController.swift
//  PlantGo
//
//  Created by 赵文赫 on 6/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{
    

    weak var listener: DatabaseListener?
    var container: NSPersistentContainer
    var exhibitionFetchedResultController: NSFetchedResultsController<Exhibition>?
    var plantFetchedResultController: NSFetchedResultsController<Plant>?
    
    override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        super.init()
        if fetchExhibitions().count == 0 {
            createDefaultEntry()
        }
    }
    
    func cleanUp() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                fatalError("Fail to save core data: \(error)")
            }
        }
    }
    
    func addExhibition(name: String, desc: String, lat: Double, long: Double, iconPath: String) -> Exhibition {
        let exhibition = NSEntityDescription
            .insertNewObject(forEntityName: "Exhibition",
                             into: container.viewContext) as! Exhibition
        exhibition.name = name
        exhibition.desc = desc
        exhibition.lat = lat
        exhibition.long = long
        exhibition.iconPath = iconPath
        return exhibition
        
    }
    
    func addPlant(name: String, scientificName: String, yearDiscovered: Int16, family: String, imgPath: String) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: container.viewContext) as! Plant
        plant.name = name
        plant.scientificName = scientificName
        plant.yearDiscovered = yearDiscovered
        plant.family = family
        plant.imgPath = imgPath
        return plant
    }
    
    func addPlant(plantData: PlantData) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: container.viewContext) as! Plant
        plant.name = plantData.name
        plant.scientificName = plantData.scientificName
        plant.yearDiscovered = Int16(plantData.yearDiscovered ?? 0)
        plant.family = plantData.family
        plant.imgPath = plantData.imgPath
        return plant
    }
    
    func addPlantToExhibition(plant: Plant, to exhibition: Exhibition) -> Bool {
        guard let plants = exhibition.exbihitionPlant, plants.contains(plant) == false else{
            return false
        }
        exhibition.addToExbihitionPlant(plant)
        return true
    }
    
    func deleteExhibition(exhibition: Exhibition) {
        container.viewContext.delete(exhibition)
    }
    
    func deletePlant(plant: Plant) {
        container.viewContext.delete(plant)
    }
    
    func addListener(listener: DatabaseListener) {
        self.listener = listener
        if listener.listenerType == .exhibitions {
            listener.onExhibitionListChange(change: .update, exhibitions: fetchExhibitions())
        } else if listener.listenerType == .plants {
            listener.onPlantListChange(change: .update, plants: fetchPlants())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        self.listener = nil
    }
    
    
    func fetchExhibitions() -> [Exhibition] {
        if exhibitionFetchedResultController == nil {
            let fetchRequest: NSFetchRequest<Exhibition> = Exhibition.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            exhibitionFetchedResultController = NSFetchedResultsController<Exhibition>(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            exhibitionFetchedResultController?.delegate = self
        }
        do {
            try exhibitionFetchedResultController?.performFetch()
        } catch {
            print("Fetch Failed: \(error)")
        }
        return exhibitionFetchedResultController?.fetchedObjects ?? [Exhibition]()
    }
    
    func fetchPlants() -> [Plant] {
        if plantFetchedResultController == nil {
            let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            plantFetchedResultController = NSFetchedResultsController<Plant>(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            plantFetchedResultController?.delegate = self
        }
        do {
            try plantFetchedResultController?.performFetch()
        } catch {
            print("Fetch Failed: \(error)")
        }
        return plantFetchedResultController?.fetchedObjects ?? [Plant]()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == exhibitionFetchedResultController && listener?.listenerType == .exhibitions {
            listener?.onExhibitionListChange(change: .update, exhibitions: fetchExhibitions())
        } else if controller == plantFetchedResultController && listener?.listenerType == .plants {
            listener?.onPlantListChange(change: .update, plants: fetchPlants())
        }
    }
    
    func createDefaultEntry(){
        let exhib1 = addExhibition(name: "Guilfoyle's Volcano", desc: "Guilfoyle’s Volcano was built in 1876 and was used to store water for Melbourne Gardens. After lying idle for 60 years, it is now restored as part of a significant landscape development project called Working Wetlands. ", lat: -37.832307, long: 144.983609, iconPath: "https://lh5.googleusercontent.com/p/AF1QipMupvIiSFD4fUZLhlEGcrIeoEgAi7NTchOWlc-X=w408-h306-k-no")
        let exhib1Plant1 = addPlant(name: "Parry's agave", scientificName: "Agave parryi", yearDiscovered: 2000, family: "Asparagaceae", imgPath: "")
        exhib1.addToExbihitionPlant(exhib1Plant1)
        
        let exhib2 = addExhibition(name: "Herb Garden", desc: "A wide range of herbs from well known leafy annuals such as Basil and Coriander, to majestic mature trees such as the Camphor Laurels Cinnamomum camphora and Cassia Bark Tree Cinnamomum burmannii. The large trees are remnants from the original 1890s Medicinal Garden. Plants displayed are from all over the world including Australia, and several are rare or have been collected from the wild.", lat: -37.831376, long: 144.979380, iconPath: "https://www.rbg.vic.gov.au/images/gallery/323/img_1075__large.jpg")
        
        let exhib2Plant1 = addPlant(name: "Lavender", scientificName: "Lavandula", yearDiscovered: 2000, family: "Lamiaceae", imgPath: "https://upload.wikimedia.org/wikipedia/commons/6/60/Single_lavendar_flower02.jpg")
        exhib2.addToExbihitionPlant(exhib2Plant1)
        
        let _ = addExhibition(name: "Grey Garden", desc: "Grey plants from around the world show variation in color and texture. The silver or grey coloring is due to leaf hairs, scales or waxy coating. These leaf protections allow survival in tough conditions and adverse growing environments.", lat: -37.826537, long: 144.979252, iconPath: "https://www.rbg.vic.gov.au/images/gallery/313/gazania-rigens-(treasure-fl__large.jpg")
        
        let _ = addExhibition(name: "Oak Collection", desc: "The great trees of Melbourne Gardens are spectacular throughout the year, but autumn is a particularly special time when the elms, oaks, and many other deciduous trees explode into a mass of vibrant yellow, red and orange. ", lat: -37.830720, long: 144.977984, iconPath: "https://www.rbg.vic.gov.au/images/gallery/353/img_5793__large.jpg")
        
        let _ = addExhibition(name: "Southern China Collection", desc: "China has 1/8th of the world’s plants. Many of these are important in Chinese culture and have been cultivated and celebrated in art and everyday life for centuries. Some plants are medicinal or useful for fiber or festivals and others are highly ornamental. Although not a traditional Chinese garden, the layout uses elements of Chinese garden design. Views to the Ornamental Lake reveal still water reflecting the surrounding landscape. ", lat: -37.827160, long: 144.980559, iconPath: "https://www.rbg.vic.gov.au/images/gallery/403/alstonia_yunnanesis_china_collection_by_chazel__large.jpg")
    }

}
