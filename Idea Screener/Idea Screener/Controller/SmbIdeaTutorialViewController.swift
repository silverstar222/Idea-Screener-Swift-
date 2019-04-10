//
//  SmbIdeaTutorialViewController.swift
//  Idea Screener
//
//  Created by Silver on 05.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class SmbIdeaTutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startBtnTap(_ sender: UIButton) {
        
        UserDefaults.standard.setValue(true, forKey: .keyForSmbIdeaTutorial)
        
        performSegue(withIdentifier: "GotoSmbIdeaSegue", sender: nil)
        
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
