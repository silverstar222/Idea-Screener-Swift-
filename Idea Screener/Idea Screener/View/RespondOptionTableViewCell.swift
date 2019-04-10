//
//  RespondOptionTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 03.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class RespondOptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var optionImageView: UIImageView!
    
    @IBOutlet weak var optionPlayerView: PlayerView!
    
    @IBOutlet weak var optionTextView: UITextView!
    
    @IBOutlet weak var optionPlayBtn: UIButton!
    
    @IBOutlet weak var optionNameLabel: UILabel!
    
    @IBOutlet weak var optionCheckImageView: UIImageView!
    
    var videoIsPlaying = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
