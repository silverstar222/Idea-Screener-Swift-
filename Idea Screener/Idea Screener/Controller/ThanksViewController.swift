//
//  ThanksViewController.swift
//  Idea Screener
//
//  Created by Silver on 10.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class ThanksViewController: UIViewController {

    @IBOutlet weak var modalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // Scroll TextView to the top
    //        override func updateViewConstraints() {
    //            super.updateViewConstraints()
    //        }
    //
    //        override func viewDidLayoutSubviews() {
    //            textView.setContentOffset(.zero, animated: false)
    //        }
    
    @IBAction func dismissModalView(_ sender: UIButton) {
        
         self.dismiss(animated: false)
        
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
