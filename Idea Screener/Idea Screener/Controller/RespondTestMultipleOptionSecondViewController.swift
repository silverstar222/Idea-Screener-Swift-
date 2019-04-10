//
//  RespondTestMultipleOptionSecondViewController.swift
//  Idea Screener
//
//  Created by Silver on 03.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class RespondTestMultipleOptionSecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var solutionTableView: UITableView!
    
    @IBOutlet weak var solutionTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var problemLabel: UILabel!
    
    @IBOutlet weak var relevanceSlider: UISlider!
    
    @IBOutlet weak var usefulnessSlider: UISlider!
    
    @IBOutlet weak var uniquenessSlider: UISlider!
    
    @IBOutlet weak var shareabilitySlider: UISlider!
    
    @IBOutlet weak var purchaseIntentSlider: UISlider!
    
    @IBOutlet weak var feedbackTextView: UITextView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //       let x = Int(round(slider.value)) // x is Int
        
        problemLabel.text = respondSurvey.problem
        
        notificationStart = false
        
        self.hideKeyboardWhenTappedAround()
        
        registerForKeyboardNotifications()
        
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func confirmBtnTap(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "respondThanksVCID") as! ThanksViewController
        self.present(vc, animated: false) {
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SolutionCell", for: indexPath) as! RespondOptionTableViewCell
        
        //        cell.optionTextView.text = respondSurvey.solutions![indexPath.row].content
        
        // if image = show image
        // if video = show video ..
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            
            self.solutionTableViewHeightConstraint.constant = self.solutionTableView.contentSize.height
        }
        
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func kbWillShow(_ notification:Notification) {
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        
        bottomViewConstraint.constant = kbFrameSize.height - 65 - 34
        
        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height * 6)
        
        
    }
    
    @objc func kbWillHide() {
        
        scrollView.contentOffset = CGPoint.zero
        
        bottomViewConstraint.constant = 0
        
        
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
