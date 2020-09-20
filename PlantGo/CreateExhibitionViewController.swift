//
//  CreateExhibitionViewController.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit
import CoreLocation

class CreateExhibitionViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseController: DatabaseProtocol?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var exhibition: Exhibition?
    var imageIsChanged = false
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    @IBOutlet weak var latTF: UITextField!
    @IBOutlet weak var longTF: UITextField!
    @IBOutlet weak var useCurrentLocationButton: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBAction func addImage(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            controller.sourceType = .camera
            self.present(controller, animated: true, completion: nil)
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
        let albumAction = UIAlertAction(title: "Photo Album", style: .default) { _ in
            controller.sourceType = .savedPhotosAlbum
            self.present(controller, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(cameraAction)
        }
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
                                info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            addImageButton.setImage(pickedImage, for: .normal)
            imageIsChanged = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        let filename: String? = {
            if self.imageIsChanged {
                let date = UInt(Date().timeIntervalSince1970)
                let filename = "\(date).jpg"
                guard let data = self.addImageButton.image(for: .normal)?.jpegData(compressionQuality: 0.8) else {
                    return nil
                }
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentsDirectory = paths[0]
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                
                do {
                    try data.write(to: fileURL)
                }   catch {
                    print(error.localizedDescription, "Error")
                }
                return filename
            }
            return nil
        }()
        if exhibition != nil {
            exhibition?.name = name
            exhibition?.desc = desc
            exhibition?.lat = lat
            exhibition?.long = long
            if filename != nil {
                exhibition?.iconPath = filename
            }
        } else {
            let _ = databaseController?.addExhibition(name: name, desc: desc, lat: lat, long: long, iconPath: filename ?? "placeholder.jpg")
        }
        navigationController?.popViewController(animated: true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
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
        nameTF.delegate = self
        descTF.delegate = self
        latTF.delegate = self
        longTF.delegate = self
        view.addGestureRecognizer(endEditingRecognizer())
        navigationController?.navigationBar.addGestureRecognizer(endEditingRecognizer())
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus != .authorizedWhenInUse {
            // If not currently authorised, hide button
            useCurrentLocationButton.isHidden = true
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        if exhibition != nil {
            nameTF.text = exhibition?.name
            descTF.text = exhibition?.desc
            latTF.text = String((exhibition?.lat)!)
            longTF.text = String((exhibition?.long)!)
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
