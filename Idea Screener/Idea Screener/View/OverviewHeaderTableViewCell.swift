//
//  OverviewOptionTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 11.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class OverviewHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var optionNameLabel: UILabel!
    
    @IBOutlet weak var optionImageView: UIImageView!
    
    @IBOutlet weak var progressBackView: DesignableView!
    
    @IBOutlet weak var progressFrontView: DesignableView!
    
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var optionPlayerView: PlayerView!
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var optionTextView: UITextView!
    
    @IBOutlet weak var optionContentView: UIView!
    
    var videoIsPlaying = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        contentTableView.frame = contentTableView.contentSize
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
