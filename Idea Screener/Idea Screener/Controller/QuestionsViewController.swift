//
//  QuestionsViewController.swift
//  Idea Screener
//
//  Created by Silver on 05.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController {
    
    var optionData: OptionData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func okBtnTap(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "GotoBillingInformationSegue", sender: optionData)
        
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoBillingInformationSegue" {
            if let billingInformationViewController = segue.destination as? BillingInformationViewController {
                if let dataToPass = sender as? OptionData {
                    billingInformationViewController.optionData = dataToPass
                }
            }
        }
    }
    
    
}
