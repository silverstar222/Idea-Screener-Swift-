//
//  RespondTestMultipleOptionViewFirstController.swift
//  Idea Screener
//
//  Created by Silver on 03.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class RespondTestMultipleOptionViewFirstController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var optionsTableView: UITableView!
    
    @IBOutlet weak var optionsTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var problemLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        problemLabel.text = respondSurvey.problem
        
        notificationStart = false
        
        optionsTableViewHeightConstraint.constant = optionsTableView.contentSize.height
        
    }
    
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (respondSurvey.solutions?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: "MultipleChoiceCell", for: indexPath) as! RespondOptionTableViewCell
        
        cell.optionTextView.text = respondSurvey.solutions![indexPath.row].content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RespondOptionTableViewCell
        
        cell.optionCheckImageView.image = #imageLiteral(resourceName: "ic_checkmark")
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RespondOptionTableViewCell
        
        cell.optionCheckImageView.image = #imageLiteral(resourceName: "ic_uncheckedmark")
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            
            self.optionsTableViewHeightConstraint.constant = self.optionsTableView.contentSize.height
        }
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
