//
//  DropTableViewCell.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit

class DropTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var machineNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
