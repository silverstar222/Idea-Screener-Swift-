//
//  SingleReportSolutionTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 07.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class SingleReportSolutionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var optionTextView: UITextView!
    
    @IBOutlet weak var optionImageView: UIImageView!
    
    @IBOutlet weak var optionPlayerView: PlayerView!
    
    @IBOutlet weak var playBtn: UIButton!
    
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
