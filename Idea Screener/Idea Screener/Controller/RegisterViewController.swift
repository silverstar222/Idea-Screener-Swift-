//
//  RegisterViewController.swift
//  Idea Screener
//
//  Created by Silver on 06.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var createAccBtn: UIButton!
    
    let context = CoreDataManager.instance.persistentContainer.viewContext
    
    var errorsArray = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        self.hideKeyboardWhenTappedAround()
        
        registerForKeyboardNotifications()
        
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    func createUser(accessToken: String) {
        
        let user = User(context: context)
        
        user.name = nameTextField.text
        user.email = emailTextField.text
        user.password = passwordTextField.text
        user.usertoken = accessToken
        
        USER_TOKEN = accessToken
        
    }
    
    func performRegistration(complete: @escaping RegistrationComplete) {
        
        let stringUrl = REGISTRATION_URL
        
        let parameters: Parameters = [
            "name": nameTextField.text!,
            "email": emailTextField.text!,
            "password": passwordTextField.text!,
            "password_confirmation": passwordTextField.text!,
            "push_token": DEVICE_TOKEN
        ]
        
        let url = URL(string: stringUrl)!
        
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding() as ParameterEncoding, headers: nil).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        
                        complete(false)
                        return
                        
                    }
                    
                    if let response:Dictionary<String,Any> = object["response"] as? Dictionary {
                        
                        if let accessToken = response["access_token"] as? String {
                            self.createUser(accessToken: accessToken)
                        }
                    }
                    
                    if let errors:Dictionary<String,Any> = object["errors"] as? Dictionary {
                        
                        if let name: Array<String> = errors["name"] as? Array {
                            
                            for error in name {
                                self.errorsArray.append("Name " + error)
                            }
                        }
                        
                        if let email: Array<String> = errors["email"] as? Array {
                            
                            for error in email {
                                self.errorsArray.append("Email " + error)
                            }
                        }
                        
                        if let password: Array<String> = errors["password"] as? Array {
                            
                            for error in password {
                                self.errorsArray.append("Password " + error)
                            }
                        }
                        
//                        if let passwordConfirmation: Array<String> = errors["password_confirmation"] as? Array {
//
//                            for error in passwordConfirmation {
//                                self.errorsArray.append("Password confirmation " + error)
//                            }
//                        }
                        
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
    
    @IBAction func createAccBtnTap(_ sender: UIButton) {
        sender.isEnabled = false
        
        performRegistration { [unowned self] (result) in
            sender.isEnabled = true
            if result == true {
                notificationStart = false
                // Save the context.
                do {
                    try self.context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
                CURRENT_USER_EMAIL = self.emailTextField.text!
                self.performSegue(withIdentifier: "GotoMainSegue", sender: nil)
            } else {
                
                var errorList = ""
                for error in self.errorsArray {
                    errorList = errorList + error + "\n"
                }
                
//                if self.errorsArray.contains("Signature has expired") {
//                    DispatchQueue.main.async {
//                        TokenHandler.shared.showLoginAlert(vc: self)
//                    }
//
//                } else {
                    let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: {
                        self.errorsArray.removeAll()
                    })
//                }
                
                
            }
        }
        
    }
    
    @IBAction func dissmissController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        
        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
        
        
    }
    
    @objc func kbWillHide() {
        scrollView.contentOffset = CGPoint.zero
        
    }
    
    func setupView() {
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
    }
    
    
    // MARK: - Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "GotoMainSegue" {
//            if let destinationNavigationController = segue.destination as? UINavigationController {
//                if let mainViewController = destinationNavigationController.topViewController as? MainViewController {
//                    if let userEmail = sender as? String {
//                        mainViewController.userEmail = userEmail
//                    }
//                }
//            }
//        }
//    }
    
}
