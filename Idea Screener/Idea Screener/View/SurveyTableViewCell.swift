//
//  SurveyTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 26.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class SurveyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusView: DesignableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var questionTextView: UITextView!
    
    @IBOutlet weak var totalCostLabel: UILabel!
    
    @IBOutlet weak var totalRespondersLabel: UILabel!
    
    @IBOutlet weak var totalRespondersImageView: UIImageView!
    
    @IBOutlet weak var currentRespondersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
