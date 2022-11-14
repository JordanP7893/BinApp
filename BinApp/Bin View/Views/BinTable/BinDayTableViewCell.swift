//
//  BinDayTableViewCell.swift
//  BinApp
//
//  Created by Jordan Porter on 04/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import UIKit

class BinDayTableViewCell: UITableViewCell {

    @IBOutlet weak var binIcon: UIImageView!
    @IBOutlet weak var binTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
