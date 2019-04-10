//
//  OptionTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 25.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

var globalOptionTagId = Int()

class OptionTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var optionTextView: UITextView!
    
    @IBOutlet weak var optionImageView: UIImageView!
    
    @IBOutlet weak var playerView: PlayerView!
    
    @IBOutlet weak var playBtn: UIButton!
        
    var videoIsPlaying = false
    
    var isEditingFirstTime = true
    
    var savedText = ""
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isEditingFirstTime || optionTextView.text == savedText {
            savedText = optionTextView.text
            optionTextView.text = ""
            isEditingFirstTime = false
        }
        
        globalOptionTagId = textView.tag

//        NotificationCenter.default.post(name: .optionTagId, object: textView.tag)

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if optionTextView.text.isEmpty {
            optionTextView.text = savedText
        }
        
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
