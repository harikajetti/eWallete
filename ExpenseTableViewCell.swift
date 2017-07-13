//
//  ExpenseTableViewCell.swift
//  eWallete
//
//  Created by HARIKA on 04/07/17.
//  Copyright © 2017 HARIKAharika. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
