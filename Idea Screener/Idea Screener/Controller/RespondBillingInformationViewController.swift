//
//  RespondBillingInformationViewController.swift
//  Idea Screener
//
//  Created by Silver on 13.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import Stripe
import CoreData

class RespondBillingInformationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var noCCTextField: UITextField!
    
    @IBOutlet weak var cvvTextField: CustomUITextField!
    
    @IBOutlet weak var expDateTextField: CustomUITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var saveCardBtn: UIButton!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var errorsArray = [String]()
    
    var respondSolution: RespondSolution!
    
    var cardSaved = false
    
    var stripeToken = ""
    
    var user: User!
    
    var card: Card!
    
    let context = CoreDataManager.instance.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        self.hideKeyboardWhenTappedAround()
        
        registerForKeyboardNotifications()
        
        if let fUser = fetchUser() {
            user = fUser
            
            nameTextField.text = user.name
            emailTextField.text = user.email
        }
        
        noCCTextField.keyboardType = UIKeyboardType.numberPad
        expDateTextField.keyboardType = UIKeyboardType.numberPad
        cvvTextField.keyboardType = UIKeyboardType.numberPad
        
        if let isCardSaved = UserDefaults.standard.object(forKey: .keyForСreditCardSaved) as? Bool {
            if isCardSaved == true {
                cardSaved = isCardSaved
                saveCardBtn.setImage(#imageLiteral(resourceName: "ic_radio_checked"), for: .normal)
                if let number = user.card?.number {
                    noCCTextField.text = number
                }
                if let cvv = user.card?.cvv {
                    cvvTextField.text = cvv
                }
                if let expDate = user.card?.expDate {
                    expDateTextField.text = expDate
                }
                
            }
        }
       
        expDateTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cvvTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case expDateTextField:
            if expDateTextField.text?.count == 2 {
                expDateTextField.text = expDateTextField.text! + "/"
            }
            if expDateTextField.text?.count == 7 {
                view.endEditing(true)
            }
        case cvvTextField:
            if cvvTextField.text?.count == 3 {
                view.endEditing(true)
            }
        default:
            break
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case expDateTextField:
            expDateTextField.text = ""
        case cvvTextField:
            cvvTextField.text = ""
        default:
            break
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if cardSaved {
            
            let card = Card(context: context)
            
            card.number = noCCTextField.text!
            card.cvv = cvvTextField.text!
            card.expDate = expDateTextField.text!
            
            user.card = card
            
            do {
                try self.context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
        }
        
    }
    
    private func performAnswerPost(complete: @escaping AnswerComplete) {
        
        let stringUrl = SURVEY_ANSWERS_URL
        
        let parameters: Parameters = [
            "survey_id": respondSolution.surveyId!,
            "answer_solution_id": respondSolution.id!,
            "user_id": respondSurvey.userId!,
            "answer_solution_rates": [
                "relevance":respondSolution.relevanceValue!,
                "uniqueness":respondSolution.uniquenessValue!,
                "usefulness":respondSolution.usefulnessValue!,
                "shareability":respondSolution.shareabilityValue!,
                "purchase_intent":respondSolution.purchaseIntentValue!
            ],
            "answer_solution_feedback": respondSolution.feedback!
        ]
        
        print("PARAMETERS -  \(parameters)")
        
        let url = URL(string: stringUrl + CURRENT_USER_ID + "/save_survey_answers")!
        
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding() as ParameterEncoding, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    if let errors = object["errors"] as? String {
                        
                        
                        if errors.contains("Survey limit reached or exceeded max participants") {
                            
                            complete(true, false)
                            return
                            
                        }
                        
                        self.errorsArray.append(errors)
                        
                        complete(false, nil)
                        return
                    }
                    
                    if let message = object["message"] as? String {
                        if message == "Success" {
                            complete(true,true)
                            return
                        }
                        if message == "Fail" {
                            complete(true,false)
                            return
                        }
                    }
                    
                }
            case .failure(let error):
                self.errorsArray.append(error.localizedDescription)
                complete(false, nil)
                return
            }
            
            
        }
        
        
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func saveCardBtnTap(_ sender: UIButton) {
        
        if cardSaved {
            saveCardBtn.setImage(#imageLiteral(resourceName: "ic_radio_btn"), for: .normal)
            cardSaved = false
            UserDefaults.standard.setValue(false, forKey: .keyForСreditCardSaved)
        } else {
            saveCardBtn.setImage(#imageLiteral(resourceName: "ic_radio_checked"), for: .normal)
            cardSaved = true
            UserDefaults.standard.setValue(true, forKey: .keyForСreditCardSaved)
        }
        
    }
    
    func postExternalStripeToken(token: String, complete: @escaping StripeTokenComplete) {
        
        let stringUrl = STRIPE_EXTERNAL_POST_URL
        
        var params: Parameters
        
        params = [
            "external": [
                "token": token
            ]
        ]
        
        let url = URL(string: stringUrl)!
        
        request(url, method: .post, parameters: params, encoding: JSONEncoding() as ParameterEncoding, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            
            switch response.result {
            case .success(let data):
                print(data)
                
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
            return
            
        }
        
        
    }
    
    func showIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func confirmBtnTap(_ sender: UIButton) {
        
        sender.isEnabled = false
        showIndicator()
        
        // Initiate the card
        let cardParams = STPCardParams()
        
        if self.expDateTextField.text?.isEmpty == false {
            // Split the expiration date to extract Month & Year
            let expirationDate = self.expDateTextField.text!.components(separatedBy: "/")
            let expMonth = UInt(expirationDate[0])
            let expYear = UInt(expirationDate[1])
            
            cardParams.number = self.noCCTextField.text
            cardParams.expMonth = expMonth!
            cardParams.expYear = expYear!
            cardParams.cvc = self.cvvTextField.text
            cardParams.currency = "usd"
            
        }
        
        STPAPIClient.shared().createToken(withCard: cardParams) { [unowned self] (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                
                if let err = error {
                    let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                    sender.isEnabled = true
                    self.hideIndicator()
                }
                return
                
            }
            
            self.stripeToken = token.tokenId
            
            self.postExternalStripeToken(token: self.stripeToken, complete: { (result) in
                if result {
                    self.performAnswerPost { (result, success) in
                        if result {
                            if success! {
                                DispatchQueue.main.async {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "respondThanksVCID") as! ThanksViewController
                                    self.present(vc, animated: false) {
                                        DispatchQueue.main.async {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "respondSorryVCID") as! ThanksViewController
                                    self.present(vc, animated: false) {
                                        DispatchQueue.main.async {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }
                                }
                            }
                        } else {
                            
                            var errorList = ""
                            for error in self.errorsArray {
                                errorList = errorList + error + "\n"
                            }
                            
                            if self.errorsArray.contains("Signature has expired") {
                                DispatchQueue.main.async {
                                    TokenHandler.shared.showLoginAlert(vc: self)
                                }
                                
                            } else {
                                let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(alertAction)
                                DispatchQueue.main.async {
                                    self.present(alert, animated: true, completion: {
                                        self.errorsArray.removeAll()
                                    })
                                }
                            }
                        }
                    }
                    
                    sender.isEnabled = true
                    self.hideIndicator()
                    
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
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: {
                                self.errorsArray.removeAll()
                            })
                        }
                    }
                    
                    sender.isEnabled = true
                    self.hideIndicator()
                }
                
                
            })
            
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
        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
        noCCTextField.attributedPlaceholder = NSAttributedString(string: "No CC",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
        expDateTextField.attributedPlaceholder = NSAttributedString(string: "Expired Date",
                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1.0)])
        
        cvvTextField.attributedPlaceholder = NSAttributedString(string: "CVV",
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
