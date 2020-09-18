//
//  AllExhibitionsTableViewController.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit
import MapKit

class AllExhibitionsTableViewController: UITableViewController, DatabaseListener, CLLocationManagerDelegate {
    
    var listenerType: ListenerType = .exhibitions
    var exhibitions = [Exhibition]()
    weak var mapViewController: HomeViewController?
    weak var databaseController: DatabaseProtocol?
    var selectedExhibition: Exhibition?
    var locationManager = CLLocationManager()
    var geofences = [CLCircularRegion]()
    //var imgs = [String: UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let app = UIApplication.shared.delegate as! AppDelegate
        databaseController = app.databaseController
        mapViewController?.mapView.annotations.forEach(){ annotation in
            if annotation.title == "Royal Botanic Garden" {
                return
            }
            let geofence =  CLCircularRegion(center: annotation.coordinate, radius: 100,
                                             identifier: annotation.title!!)
            geofence.notifyOnExit = true
            geofence.notifyOnEntry = true
            locationManager.startMonitoring(for: geofence)
            geofences.append(geofence)
        }
        locationManager.delegate = self
         locationManager.requestAlwaysAuthorization()
       
    }

    
    func onExhibitionListChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        self.exhibitions = exhibitions
        self.tableView.reloadData()
    }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tableView.rowHeight = 100
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Leaving an exhibition",
                                      message: "You have left \(region.identifier)",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
                                        UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Entering an exhibition",
                                      message: "You have entered \(region.identifier)",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
                                        UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return exhibitions.count
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitionCell", for: indexPath) as! ExhibitionTableViewCell
            let exhibition = exhibitions[indexPath.row]
            cell.titleLable.text = exhibition.name
            cell.titleLable.numberOfLines = 0
            cell.detailLable.text = exhibition.desc
            cell.detailLable.textColor = .secondaryLabel
            cell.detailLable.numberOfLines = 5
            /*if imgs.count == exhibitions.count {
                cell.iconImgView?.image = imgs[exhibition.iconPath!]

            }*/
            downloadImg(view: cell.iconImgView, path: exhibition.iconPath!)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        cell.textLabel?.textColor = .secondaryLabel
        cell.textLabel?.text = "\(exhibitions.count) exhibitions found, click + to add a new one"
        return cell
        
    }
    

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 0 {
            databaseController?.deleteExhibition(exhibition: exhibitions[indexPath.row])
            geofences.remove(at: indexPath.row)
            mapViewController?.mapView.annotations.forEach(){ annotation in
                let exhibition = exhibitions[indexPath.row]
                if annotation.title == exhibition.name && annotation.coordinate.latitude == exhibition.lat
                    && annotation.coordinate.longitude == exhibition.long {
                    self.mapViewController?.mapView.removeAnnotation(annotation)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let exhibition = exhibitions[indexPath.row]
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Exhibition detail", style: .default, handler: { _ in
                self.selectedExhibition = exhibition
                self.performSegue(withIdentifier: "exhibitionDetailSegue", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Show in map", style: .default, handler: { _ in
                self.mapViewController?.moveCamera(lat: exhibition.lat, long: exhibition.long)
                self.splitViewController?.showDetailViewController(self.mapViewController!, sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
 /*
    func downloadImgs(){
        imgs.removeAll()
        exhibitions.forEach(){exhibition in
            let url = URL(string: exhibition.iconPath!)!
            let task = URLSession.shared.dataTask(with: url){data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                } else{
                    self.imgs[exhibition.iconPath!] = (UIImage(data: data!)!)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            task.resume()
        }
    }
 */
    
    func downloadImg(view: UIImageView, path: String){
        guard let url = URL(string: path) else {
            view.image = UIImage(named: "placeholder.jpg")
            return
        }
        let task = URLSession.shared.dataTask(with: url){data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    view.image = UIImage(data: data!)!
                }
            }
            
        }
        task.resume()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exhibitionDetailSegue" {
            let destination = segue.destination as! ExhibitionDetailTableViewController
            destination.exhibition = self.selectedExhibition
        }
    }
    
}
