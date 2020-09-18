//
//  AddPlantTableViewController.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit

class AddPlantTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating, UISearchBarDelegate {

    
   
    var exhibition: Exhibition?
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .plants
    var plants = [Plant]()
    var filteredPlants = [Plant]()
    var indicator = UIActivityIndicatorView()
    let API_PATH = "https://trefle.io/api/v1/plants/search?token=mCfhR64g8OOnmRaXCjoQE1ftE_ZyPDX1GM62R09c9Ow&q="
    var plantsFromAPI:  [PlantData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseController = (UIApplication.shared.delegate as! AppDelegate).databaseController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search More"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = searchController.searchBar.text?.lowercased() else {
            return
        }
        if keyword.count > 0 {
            filteredPlants = plants.filter() { plant -> Bool in
                guard let name = plant.name else{
                    return false
                }
                return name.lowercased().contains(keyword)
            }
        } else {
            filteredPlants = plants
        }
        tableView.reloadData()
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
        
    }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        self.plants = plants
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        plantsFromAPI = nil
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, keyword.count > 0 else {
            plantsFromAPI = nil
            return
        }
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        requestPlants(plantName: keyword)
    }
    
    func requestPlants(plantName: String){
        let urlString = API_PATH + plantName
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            do {
                let decoder = JSONDecoder()
                let volumnData = try decoder.decode(VolumnData.self, from: data!)
                if let plantDatas = volumnData.plants {
                    self.plantsFromAPI = plantDatas.filter{$0.name != nil}
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantsFromAPI?.count ?? filteredPlants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)

        if plantsFromAPI == nil {
            let plant = filteredPlants[indexPath.row]
            cell.textLabel?.text = plant.name
            return cell
        }
        cell.textLabel?.text = plantsFromAPI?[indexPath.row].name
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if plantsFromAPI != nil{
            return false
        }
        return true
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && plantsFromAPI == nil {
            self.databaseController?.deletePlant(plant: filteredPlants[indexPath.row])
            
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if plantsFromAPI == nil {
        let plant = filteredPlants[indexPath.row]
            let _ = databaseController?.addPlantToExhibition(plant: plant, to: exhibition!)
        } else {
            let _ = databaseController?.addPlantToExhibition(plant: (databaseController?.addPlant(plantData: plantsFromAPI![indexPath.row]))!,
                                                             to: exhibition!)
        }
        navigationController?.popViewController(animated: true)
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
