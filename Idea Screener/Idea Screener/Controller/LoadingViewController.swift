//
//  ViewController.swift
//  Idea Screener
//
//  Created by Silver on 02.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.performSegue(withIdentifier: "GotoLoginSegue", sender: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

