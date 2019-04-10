//
//  SmbIdeaViewController.swift
//  Idea Screener
//
//  Created by Silver on 05.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class SmbIdeaViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func singleOptionBtnTap(_ sender: UIButton) {
        
        
            self.performSegue(withIdentifier: "GotoSingleSegue", sender: nil)
        
        
    }
    
    @IBAction func MultiplyOptionBtnTap(_ sender: UIButton) {
       
            self.performSegue(withIdentifier: "GotoMultiplySegue", sender: nil)
        
        
    }
    
    @IBAction func TestMultiplyOptionBtnTap(_ sender: UIButton) {
        
        
            self.performSegue(withIdentifier: "GotoTestMultiplySegue", sender: nil)
        
        
    }
    
    
    
}
