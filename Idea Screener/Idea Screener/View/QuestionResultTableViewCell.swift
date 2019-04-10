//
//  QuestionResultTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 13.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class QuestionResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var leftSliderLabel: UILabel!
    
    @IBOutlet weak var rightSliderLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var progressBackView: DesignableView!
    
    @IBOutlet weak var progressFrontView: DesignableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
