//
//  LoginViewController.swift
//  Idea Screener
//
//  Created by Silver on 03.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var loginBtn: DesignableButton!
    
    @IBOutlet weak var fbBtn: UIButton!
    
    @IBOutlet weak var googleBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    var errorsArray = [String()]
    
    var user: User!
        
    let context = CoreDataManager.instance.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = getUser()
        
        if let user = user {
            emailTextField.text = user.email
            passwordTextField.text = user.password
        }
        
        setupView()
        
        self.hideKeyboardWhenTappedAround()
        
        registerForKeyboardNotifications()
        
    }
    
    private func getUser() -> User? {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        if let predicate = UserDefaults.standard.object(forKey: .keyForUserPredicate) as? String {
            userFetchRequest.predicate = NSPredicate(format: "email == %@", predicate)
        }
        
        do {
            let users = try context.fetch(userFetchRequest) as! [User]
            if let lastUser = users.last {
                return lastUser
            }
        } catch {
            fatalError("Failed to fetch users: \(error)")
        }
        
        return nil
    }
    
    private func getNewUser(email: String) -> User? {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetchRequest.predicate = NSPredicate(format: "email == %@", email)

        
        do {
            let users = try context.fetch(userFetchRequest) as! [User]
            if let lastUser = users.last {
                return lastUser
            }
        } catch {
            fatalError("Failed to fetch users: \(error)")
        }
        
        return nil
    }
    
    private func createUser(name: String, accessToken: String, email: String){
        
        let user = User(context: context)
        
        user.name = name
        user.email = email
        user.password = passwordTextField.text
        user.usertoken = accessToken
        
        USER_TOKEN = accessToken

    }
    
    private func performLogin(complete: @escaping LoginComplete){
        
        let stringUrl = LOGIN_URL
        
        let parameters: Parameters = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!,
            "push_token": DEVICE_TOKEN
        ]
        
        let url = URL(string: stringUrl)!
        
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding() as ParameterEncoding, headers: nil).validate(contentType: ["application/json"]).responseJSON { (response) in
            
            switch response.result {
            case .success(let data):
                
//                print(data)
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        
                        complete(false)
                        return
                        
                    }
                    
                    if let errors:Dictionary<String,Any> = object["error"] as? Dictionary {
                        
                        if let name: Array<String> = errors["user_authentication"] as? Array {
                            
                            for error in name {
                                self.errorsArray.append("User authentication " + error)
                            }
                        }
                        
                        complete(false)
                        return
                    }
                    
                    var aToken = ""
                    var uName = ""
                    
                    if let accessToken = object["access_token"] as? String {
                        aToken = accessToken
                    }
                    
                    if let name = object["name"] as? String {
                        uName = name
                    }
                    
                    if let user = self.getNewUser(email: self.emailTextField.text!) {
                        user.name = uName
                        user.usertoken = aToken
                        USER_TOKEN = aToken
                    } else {
                        self.createUser(name: uName, accessToken: aToken, email: self.emailTextField.text!)
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
    
    @IBAction func loginBtnTap(_ sender: UIButton) {
        
        sender.isEnabled = false
        performLogin { [unowned self] (result) in
            sender.isEnabled = true
            if result == true {
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
//                CURRENT_USER_ID = String(self.user.id)
                
                self.performSegue(withIdentifier: "GotoMainSegue", sender: nil)
            } else {
                
                var errorList = ""
                for error in self.errorsArray {
                    errorList = errorList + error + "\n"
                }

                    let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: {
                        self.errorsArray.removeAll()
                    })
                
            }
        }
        
        
    }
    
    
    private func performLoginWith(social:String, accessToken:String, complete: @escaping LoginComplete){
        
        var stringUrl = ""
        
        switch social {
        case "google":
            stringUrl = LOGIN_WITH_GOOGLE_URL
        case "facebook":
            stringUrl = LOGIN_WITH_FACEBOOK_URL
        default:
            break
        }
        
        let parameters: Parameters = [
            "token": accessToken,
            "push_token": DEVICE_TOKEN
        ]
        
        print(parameters)
        
        let url = URL(string: stringUrl)!
        print(url)
        
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding() as ParameterEncoding, headers: nil).validate(contentType: ["application/json"]).responseJSON { (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        
                        complete(false)
                        return
                        
                    }
                    
                    
                    var userEmail = ""
                    
                    if let email = object["email"] as? String {
                        userEmail = email
                    }
                    
                    var fullName = ""
                    var firstName = ""
                    var lastName = ""
                    
                    if let fName = object["first_name"] as? String {
                        firstName = fName
                    }
                    
                    if let lName = object["last_name"] as? String {
                        lastName = lName
                    }

                    var aToken = ""
                    
                    if let accessToken = object["access_token"] as? String {
                        aToken = accessToken
                    }
                    
                    fullName = firstName + lastName

                    CURRENT_USER_EMAIL = userEmail
                    
                    if let user = self.getNewUser(email: userEmail) {
                        user.name = fullName
                        user.usertoken = aToken
                        USER_TOKEN = aToken
                    } else {
                        self.createUser(name: fullName, accessToken: aToken, email: userEmail)
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
    
    @IBAction func fbBtnTap(_ sender: UIButton) {
        
        if let token = AccessToken.current {
            // User is logged in, do work such as go to next view controller.
            print(token.authenticationToken)
        } else {
            
            let loginManager = LoginManager()
            loginManager.logIn(readPermissions: [ .publicProfile, .email ], viewController: self) { (loginResult) in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success( _,  _, let accessToken):
//                    accessToken.userId
                    self.performLoginWith(social: "facebook", accessToken: accessToken.authenticationToken) { (result) in
                        if result {
                            
//                            self.performSegue(withIdentifier: "GotoMainSegue", sender: nil)
                            
                        } else {
                            
                            var errorList = ""
                            for error in self.errorsArray {
                                errorList = errorList + error + "\n"
                            }

                            
                            let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: {
                                self.errorsArray.removeAll()
                            })
                            
                        }
                    }
                    print(accessToken)
                    print("Logged in!")
                }
                
            }
            
        }

    }

    
    @IBAction func googleBtnTap(_ sender: UIButton) {
        googleBtn.isEnabled = false
        
        let googleInstance = GIDSignIn.sharedInstance()!
        googleInstance.delegate = self
        googleInstance.uiDelegate = self
        
        if googleInstance.hasAuthInKeychain() {
            googleInstance.signInSilently()
        } else {
            googleInstance.signIn()
        }

    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        googleBtn.isEnabled = true
        if let err = error {
            print("Sign WillDispatch \(err.localizedDescription)")
            return
        }
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Completed sign In
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                       withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
            print(user.userID)
            print(user.authentication.accessToken)
//            user.authentication
            
            performLoginWith(social: "google", accessToken: user.authentication.accessToken) { (result) in
                if result {
                    
                    
                    self.performSegue(withIdentifier: "GotoMainSegue", sender: nil)

                } else {
                    
                    var errorList = ""
                    for error in self.errorsArray {
                        errorList = errorList + error + "\n"
                    }

                    let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: {
                        self.errorsArray.removeAll()
                    })
                    
                    
                }
            }
        } else {
            print("\(error.localizedDescription)")
            return
        }
    }
    
    
    deinit {
        removeKeyboardNotifications()
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
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
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
