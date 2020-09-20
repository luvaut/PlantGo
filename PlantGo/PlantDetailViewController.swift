//
//  PlantDetailViewController.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController {
     
    var plant: Plant?

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var sNameLable: UILabel!
    @IBOutlet weak var yearLable: UILabel!
    @IBOutlet weak var familyLable: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLable.text = plant?.name
        sNameLable.text = "Scientific name: \(plant?.scientificName ?? "Unknown")"
        yearLable.text = "Year discovered: \( plant?.yearDiscovered ?? 0)"
        familyLable.text = "Family: \(plant?.family ?? "Unknown")"
        loadImage()
        
    }
    
    func loadImage(){
        let path = plant?.imgPath
        guard let url = URL(string: path!) else {
            imgView.image = UIImage(named: "placeholder.jpg")
            return
        }
        let task = URLSession.shared.dataTask(with: url){data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.imgView.image = UIImage(data: data!)!
                }
            }
            
        }
        task.resume()
        
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
