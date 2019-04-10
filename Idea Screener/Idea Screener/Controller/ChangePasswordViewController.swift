//
//  ChangePasswordViewController.swift
//  Idea Screener
//
//  Created by Silver on 10.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    let context = CoreDataManager.instance.persistentContainer.viewContext
    
    var user: User!
    
    var errorsArray = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        self.hideKeyboardWhenTappedAround()
        
        registerForKeyboardNotifications()
        
        if let fUser = fetchUser() {
            user = fUser
            
        }
        
        print("viewdidload user email - " + CURRENT_USER_EMAIL)
        
    }
    
    func fetchUser() -> User? {
        
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetchRequest.predicate = NSPredicate(format: "email == %@", CURRENT_USER_EMAIL)
        
        do {
            let users = try context.fetch(userFetchRequest) as! [User]
            print(users.count)
            if let lastUser = users.last {
                UserDefaults.standard.setValue(lastUser.email, forKey: .keyForUserPredicate)
                return lastUser
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        return nil
        
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func performPasswordUpdate(complete: @escaping UserUpdateComplete) {
        
        let stringUrl = USER_UPDATE_URL
        
        if let password = user.password {
            
            if currentPasswordTextField.text != password {
                
                self.errorsArray.append("Incorrent current password")
                
                complete(false)
                return
            }
            
        }
        


        let parameters: Parameters = [

            "password": newPasswordTextField.text!,

        ]
        
        let url = URL(string: stringUrl)!
        
        print(url)

        request(url, method: .put, parameters: parameters, encoding: JSONEncoding() as ParameterEncoding, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        
                        complete(false)
                        return
                        
                    }
                    
                    
                    
                    if let password: Array<String> = object["password"] as? Array {
                        
                        for error in password {
                            self.errorsArray.append("New password " + error)
                        }
                        
                        
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
    
    @IBAction func confirmBtnTap(_ sender: UIButton) {
        sender.isEnabled = false
        
        performPasswordUpdate { [unowned self] (result) in
            sender.isEnabled = true
            if result == true {
                
                self.user.password = self.newPasswordTextField.text!
                // Save the context.
                do {
                    try self.context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
                let alert = UIAlertController(title: nil, message: "Password has been changed!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
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
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func kbWillShow(_ notification:Notification) {
//        let userInfo = notification.userInfo
//        let kbFrameSize = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        
//        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
        
        
    }
    
    @objc func kbWillHide() {
        scrollView.contentOffset = CGPoint.zero
        
    }
    
    func setupView() {

        scrollView.contentOffset = CGPoint.zero
        
        currentPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Your current password",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
        newPasswordTextField.attributedPlaceholder = NSAttributedString(string: "New password",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
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
