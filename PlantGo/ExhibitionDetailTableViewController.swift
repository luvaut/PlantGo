//
//  ExhibitionDetailTableViewController.swift
//  PlantGo
//
//  Created by 赵文赫 on 16/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit
import MapKit

class ExhibitionDetailTableViewController: UITableViewController, DatabaseListener {
    
    var listenerType: ListenerType = .exhibitions
    weak var databaseController: DatabaseProtocol?
    
    var exhibition: Exhibition?
    var selectedPlant: Plant?

    override func viewDidLoad() {
        super.viewDidLoad()

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
    func onExhibitionListChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        tableView.reloadData()
    }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 || section == 1{
            return 1
        }
        if let num = exhibition?.exbihitionPlant?.count {
            return num + 1
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitionDetailCell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\((exhibition?.name)!)\n\n\((exhibition?.desc)!)"
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitionLocationCell", for: indexPath)
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: (exhibition?.lat)!, longitude: (exhibition?.long)!)
            geoCoder.reverseGeocodeLocation(location){ placemarks, error in
                if let street = placemarks?[0].thoroughfare, let name =  placemarks?[0].name {
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.text = "\(name), \(street)"
                } else {
                    cell.textLabel?.text = "Unknown"
                }
                
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitionPlantCell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "New Plant"
            cell.textLabel?.textColor = .systemBlue
           
           
            
        } else {
            
            cell.imageView?.isHidden = true
            cell.textLabel?.text = (exhibition?.exbihitionPlant?.allObjects[indexPath.row - 1] as! Plant).name
        }
        
        return cell
        
        // Configure the cell...

    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 || indexPath.row != 0{
            return true
        }
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 2 && indexPath.row != 0 {
            exhibition?.removeFromExbihitionPlant((exhibition?.exbihitionPlant?.allObjects[indexPath.row - 1] as! Plant))
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0  || indexPath.section == 1{
            tableView.deselectRow(at: indexPath, animated: false)
        } else if indexPath.row == 0 {
            performSegue(withIdentifier: "addPlantSegue", sender: self)
        } else {
            selectedPlant = (exhibition?.exbihitionPlant?.allObjects as! [Plant])[indexPath.row - 1]
            self.performSegue(withIdentifier: "plantDetailSegue", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlantSegue" {
            let destination = segue.destination as! AddPlantTableViewController
            destination.exhibition = self.exhibition
            
        } else if segue.identifier == "plantDetailSegue" {
            let destination = segue.destination as! PlantDetailViewController
            destination.plant = selectedPlant
        } else if segue.identifier == "editExhibitionSegue" {
            let destination = segue.destination as! CreateExhibitionViewController
            destination.exhibition = self.exhibition
            destination.navigationItem.title = "Edit Exhibition"
        }
    }
    

}
