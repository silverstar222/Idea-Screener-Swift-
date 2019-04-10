//
//  ConfirmationViewController.swift
//  Idea Screener
//
//  Created by Silver on 05.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
        
    @IBOutlet weak var dropDownBtn: UIButton!
    
    @IBOutlet var menuItemBtns: [DesignableButton]!
    
    @IBOutlet weak var confirmationTableView: UITableView!
    
    @IBOutlet weak var confirmationTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var respondersCountLabel: UILabel!
    
    @IBOutlet weak var priceForResponderLabel: UILabel!
    
    @IBOutlet weak var calcPriceLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var optionData: OptionData!
    
    let confirmationData = ["Gender","Age","HH Income","Education Level","Lifestyle","Relationship Status","Life Stage","Home Ownership"]
    
    var isFirstLaunch = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFirstLaunch = true
        
        menuItemBtns.forEach { (button) in
            button.isHidden = true
        }
        
        if let isAllQuestWatched = UserDefaults.standard.object(forKey: .keyForAllQuestions) as? Bool {
            if isAllQuestWatched == true {
                isFirstLaunch = false
            }
        }

        confirmationTableViewHeightConstraint.constant = confirmationTableView.rowHeight * CGFloat(confirmationData.count)
        
//        hideMenuWhenTappedAround()
    }
    
//    func hideMenuWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideMenu))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc func hideMenu() {
//        menuItemBtns.forEach { (button) in
//            UIView.animate(withDuration: 0.3, animations: {
//                button.isHidden = true
//                self.view.layoutIfNeeded()
//            })
//        }
//
//    }

    @IBAction func selectRespondersCountBtn(_ sender: UIButton) {
        menuItemBtns.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func menuBtnsTap(_ sender: DesignableButton) {
        respondersCountLabel.text = sender.titleLabel?.text
        
        let priceForResponderString = priceForResponderLabel.text!.replacingOccurrences(of: "$", with: "")
        let totalPrice = Double(respondersCountLabel.text!)! * Double(priceForResponderString)!
        
        totalPriceLabel.text = "$" + String(format: "%.0f", totalPrice)
        calcPriceLabel.text = "$" + String(format: "%.0f", totalPrice)
            
        menuItemBtns.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    @IBAction func goToBillingBtnTap(_ sender: UIButton) {
        
        optionData.respondentsCount = respondersCountLabel.text!
        optionData.responderPrice = "10"
        optionData.totalCost = totalPriceLabel.text!.replacingOccurrences(of: "$", with: "")
        
        if isFirstLaunch {
            UserDefaults.standard.setValue(true, forKey: .keyForAllQuestions)
            self.performSegue(withIdentifier: "GotoForAllTestSegue", sender: optionData)
        } else {
            self.performSegue(withIdentifier: "GotoBillingInformationSegue", sender: optionData)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return confirmationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = confirmationTableView.dequeueReusableCell(withIdentifier: "ConfirmationCell", for: indexPath) as! ConfirmationTableViewCell
        
        cell.leftLabel.text = confirmationData[indexPath.row]
        cell.rightLabel.text = optionData.targetAudience[indexPath.row]
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GotoForAllTestSegue" {
            if let questionsViewController = segue.destination as? QuestionsViewController {
                if let dataToPass = sender as? OptionData {
                    questionsViewController.optionData = dataToPass
                }
            }
        }
        
        if segue.identifier == "GotoBillingInformationSegue" {
            if let billingInformationViewController = segue.destination as? BillingInformationViewController {
                if let dataToPass = sender as? OptionData {
                    billingInformationViewController.optionData = dataToPass
                }
            }
        }
        
    }

}
