//
//  ExihitionTableViewCell.swift
//  PlantGo
//
//  Created by 赵文赫 on 5/9/20.
//  Copyright © 2020 LUVAUT. All rights reserved.
//

import UIKit

class ExhibitionTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!

    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var detailLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
