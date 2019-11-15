//
//  ExpenseTableViewCell.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 14/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
