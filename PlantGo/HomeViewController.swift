//
//  HomeViewController.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController, DatabaseListener{
    
    
    var listenerType: ListenerType = .exhibitions
    @IBOutlet weak var mapView: MKMapView!
    weak var databaseController: DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()

        let gardenAnnotation = ExhibitionAnnotation(title: "Royal Botanic Garden",
                                             sub: "Victoria, Melbourne",
                                             lat: -37.8304, long: 144.9796)
        mapView.addAnnotation(gardenAnnotation)
        moveCamera(lat: gardenAnnotation.coordinate.latitude, long: gardenAnnotation.coordinate.longitude)
        databaseController = (UIApplication.shared.delegate as! AppDelegate).databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func moveCamera(lat: Double, long: Double){
        let annotation = mapView.annotations.first{$0.coordinate.latitude == lat && $0.coordinate.longitude == long}!
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func newExhibitionAdded(exhibition: Exhibition) {
        let annotation = ExhibitionAnnotation(title: exhibition.name ?? "Unknown", sub: "", lat: exhibition.lat, long: exhibition.long)
        mapView.addAnnotation(annotation)
    }
    
    func onExhibitionListChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        exhibitions.forEach(){
            newExhibitionAdded(exhibition: $0)
        }
    }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        
    }
    
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

