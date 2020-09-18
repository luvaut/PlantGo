//
//  CreateExhibitionViewController.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit
import CoreLocation

class CreateExhibitionViewController: UIViewController, CLLocationManagerDelegate {
    
    var databaseController: DatabaseProtocol?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var exhibition: Exhibition?
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    @IBOutlet weak var latTF: UITextField!
    @IBOutlet weak var longTF: UITextField!
    @IBOutlet weak var useCurrentLocationButton: UIButton!
    
    @IBAction func UseCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation {
            latTF.text = "\(currentLocation.latitude)"
            longTF.text = "\(currentLocation.longitude)"
        } else {
            let alertController = UIAlertController(title: "Location Not Found",
                                                    message: "The location has not yet been determined.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style:
                .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func Save(_ sender: Any) {
        let name = nameTF.text!
        let desc = descTF.text!
        if name.count == 0 || desc.count == 0 {
            let alertController = UIAlertController(title: "Form Incomplete",
                                                    message: "Please complete the form", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        guard let lat = Double(latTF.text!), let long = Double(longTF.text!) else {
            let alertController = UIAlertController(title: "Co-ordinates invalid",
                                                    message: "Lat & Long must be numbers", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        if exhibition != nil {
            exhibition?.name = name
            exhibition?.desc = desc
            exhibition?.lat = lat
            exhibition?.long = long
            return
        }
        let _ = databaseController?.addExhibition(name: name, desc: desc, lat: lat, long: long, iconPath: "")
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = (UIApplication.shared.delegate as! AppDelegate).databaseController
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus != .authorizedWhenInUse {
            // If not currently authorised, hide button
            useCurrentLocationButton.isHidden = true
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            if exhibition != nil {
                nameTF.text = exhibition?.name
                descTF.text = exhibition?.desc
                latTF.text = String((exhibition?.lat)!)
                longTF.text = String((exhibition?.long)!)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            useCurrentLocationButton.isHidden = false
        }
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
