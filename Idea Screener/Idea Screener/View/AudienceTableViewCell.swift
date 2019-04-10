//
//  AudienceGenderTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 05.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class AudienceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
