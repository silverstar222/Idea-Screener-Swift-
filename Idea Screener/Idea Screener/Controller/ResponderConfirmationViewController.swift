//
//  ResponderConfirmationViewController.swift
//  Idea Screener
//
//  Created by Silver on 10.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ResponderConfirmationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var confirmationTableView: UITableView!
    
    @IBOutlet weak var confirmationTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    let context = CoreDataManager.instance.persistentContainer.viewContext
    
    var user: User!
    
    var passedData: [String]!
    
    var errorsArray = [String()]
    
    let confirmationData = ["Gender","Age","HH Income","Education Level","Lifestyle","Relationship Status","Life Stage","Home Ownership"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fUser = fetchUser() {
            user = fUser
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.confirmationTableViewHeightConstraint.constant = self.confirmationTableView.contentSize.height
        }
    }
    
    func fetchUser() -> User? {
        
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetchRequest.predicate = NSPredicate(format: "email == %@", CURRENT_USER_EMAIL)
        
        do {
            let users = try context.fetch(userFetchRequest) as! [User]
            if let lastUser = users.last {
                UserDefaults.standard.setValue(lastUser.email, forKey: .keyForUserPredicate)
                return lastUser
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        return nil
        
    }
    
    func updateUserProfile(complete: @escaping ProfileUpdateComplete) {
        
        let stringUrl = PROFILE_UPDATE_URL
        
        let url = URL(string: stringUrl)!
        
        let parameters: Parameters = [
            "gender": passedData[0],
            "age_category": passedData[1],
            "hh_income": passedData[2],
            "education_level": passedData[3],
            "life_style": passedData[4],
            "relationship_status": passedData[5],
            "life_stage": passedData[6],
            "home_ownership": passedData[7],
            "is_completed": true
        ]
        
        
        request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: ["Authorization":"Bearer " + user.usertoken!]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
                        
            switch response.result {
            case .success(let data):
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        complete(false)
                        return
                        
                    }
                    
                }
                
            case .failure(let error):
                self.errorsArray.append(error.localizedDescription)
                complete(false)
                return
            }
            
            complete(true)
            
        }
        
        
    }
    
    func crtUserAccount(complete: @escaping CrtUserAccComplete) {
        
        let stringUrl = STRIPE_ACCOUNT_POST_URL
        
        let url = URL(string: stringUrl)!
        
//        let parameters: Parameters = [
//            "verification": [
//                "disabled_reason": "fields_needed",
//                "due_by": nil,
//                "fields_needed": [ "legal_entity.dob.day", "legal_entity.dob.month", "legal_entity.dob.year", "legal_entity.first_name", "legal_entity.last_name", "legal_entity.type", "tos_acceptance.date", "tos_acceptance.ip"  ]
//
//            ]
//        ]
        
//        "verification": {
//            "disabled_reason": "fields_needed",
//            "due_by": null,
//            "fields_needed": [
//            "legal_entity.dob.day",
//            "legal_entity.dob.month",
//            "legal_entity.dob.year",
//            "legal_entity.first_name",
//            "legal_entity.last_name",
//            "legal_entity.type",
//            "tos_acceptance.date",
//            "tos_acceptance.ip"
//            ]
//        }
        
        
        request(url, method: .post, parameters: nil, encoding: JSONEncoding() as ParameterEncoding, headers: ["Authorization":"Bearer " + user.usertoken!]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            switch response.result {
            case .success(let data):
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        complete(false)
                        return
                        
                    }
                    
                }
                
            case .failure(let error):
                self.errorsArray.append(error.localizedDescription)
                complete(false)
                return
            }
            
            complete(true)
            
        }
        
        
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func confirmBtnTap(_ sender: UIBarButtonItem) {
        
        updateUserProfile { [unowned self] (result) in
            if result == true {
                self.crtUserAccount(complete: { (result) in
                    if result {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "thanksVCID") as! ThanksViewController
                        self.present(vc, animated: false) {
                            DispatchQueue.main.async {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    } else {
                        
                        var errorList = ""
                        for error in self.errorsArray {
                            errorList = errorList + error + "\n"
                        }
                        
                        if self.errorsArray.contains("Signature has expired") || self.errorsArray.contains("Signature verification raised") || self.errorsArray.contains("Not enough or too many segments") {
                            DispatchQueue.main.async {
                                TokenHandler.shared.showLoginAlert(vc: self)
                            }
                            
                        } else {
                            let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: {
                                self.errorsArray.removeAll()
                            })
                        }
                        
                        
                    }
                })

            } else {
                
                var errorList = ""
                for error in self.errorsArray {
                    errorList = errorList + error + "\n"
                }
                
                if self.errorsArray.contains("Signature has expired") || self.errorsArray.contains("Signature verification raised") || self.errorsArray.contains("Not enough or too many segments") {
                    DispatchQueue.main.async {
                        TokenHandler.shared.showLoginAlert(vc: self)
                    }
                    
                } else {
                    let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: {
                        self.errorsArray.removeAll()
                    })
                }
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return confirmationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = confirmationTableView.dequeueReusableCell(withIdentifier: "ConfirmationCell", for: indexPath) as! ConfirmationTableViewCell
        
        cell.leftLabel.text = confirmationData[indexPath.row]
        cell.rightLabel.text = passedData[indexPath.row]
        
        return cell
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
