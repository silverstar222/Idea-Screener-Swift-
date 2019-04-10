//
//  FeedbackTableViewCell.swift
//  Idea Screener
//
//  Created by Silver on 12.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class FeedbackTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var feedbackTableView: UITableView!
    
    @IBOutlet weak var feedbackTableViewHeightConstraint: NSLayoutConstraint!
    
    var feedbacks = [String]()

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            
            
            var frame = self.feedbackTableView.frame
            frame.size.height = self.feedbackTableView.contentSize.height
            self.feedbackTableView.frame = frame
            
            self.feedbackTableViewHeightConstraint.constant = frame.size.height
            
            NotificationCenter.default.post(name: .feedbackTableHeight, object: frame)
            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedbackTableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackOptionTableViewCell
        
        cell.msgTextLabel.text = feedbacks[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        switch tableView {
//        case feedbackTableView:
//            if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
//                feedbackTableViewHeightConstraint.constant = feedbackTableView.contentSize.height
//
//
//            }
//
//        default:
//            return
//        }
//
//    }

    
    
    
    

}
