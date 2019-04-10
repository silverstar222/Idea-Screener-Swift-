//
//  BillingInformationViewController.swift
//  Idea Screener
//
//  Created by Silver on 06.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import Stripe
import CoreData

class BillingInformationViewController: UIViewController, UITextFieldDelegate {
    
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
    
    var optionData: OptionData!
    
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
    
    private func postSurvey(complete: @escaping SurveyPostComplete) {
        
        let stringUrl = SURVEYS_URL
        
        var parameters: Parameters
        
        switch optionData.solutions.count {
        case 1:
            var firstVideo = Data()
            var firstImage = Data()
            
            if let video = optionData.solutions[0].videoData {
                firstVideo = video
            }
            
            if let image = optionData.solutions[0].imageData {
                firstImage = image
            }
            
            parameters = [
                "title": optionData.problem!,
                "status": "open",
                "max_participants_count": optionData.respondentsCount!,
                "cost_per_user": "10",
//                "total_price": Double(optionData.respondentsCount!)! * 10,
                "survey_type": optionData.type!,
                "questions_attributes[0][content]": optionData.problem!,
                "solutions_attributes[0][content]": optionData.solutions[0].content,
                "solutions_attributes[0][video]": firstVideo,
                "solutions_attributes[0][image]": firstImage,
                "target_audience[gender]": optionData.targetAudience[0],
                "target_audience[age_category]": optionData.targetAudience[1],
                "target_audience[hh_income]": optionData.targetAudience[2],
                "target_audience[education_level]": optionData.targetAudience[3],
                "target_audience[life_style]": optionData.targetAudience[4],
                "target_audience[relationship_status]": optionData.targetAudience[5],
                "target_audience[life_stage]": optionData.targetAudience[6],
                "target_audience[home_ownership]": optionData.targetAudience[7],
            ]
        case 2:
            var firstVideo = Data()
            var firstImage = Data()
            var secondVideo = Data()
            var secondImage = Data()
            
            if let video = optionData.solutions[0].videoData {
                firstVideo = video
            }
            
            if let image = optionData.solutions[0].imageData {
                firstImage = image
            }
            
            if let video = optionData.solutions[1].videoData {
                secondVideo = video
            }
            
            if let image = optionData.solutions[1].imageData {
                secondImage = image
            }
            
            parameters = [
                "title": optionData.problem!,
                "status": "open",
                "max_participants_count": optionData.respondentsCount!,
                "cost_per_user": "10",
                //                "total_price": Double(optionData.respondentsCount!)! * 10,
                "survey_type": optionData.type!,
                "questions_attributes[0][content]": optionData.problem!,
                "solutions_attributes[0][content]": optionData.solutions[0].content,
                "solutions_attributes[0][video]": firstVideo,
                "solutions_attributes[0][image]": firstImage,
                "solutions_attributes[1][content]": optionData.solutions[1].content,
                "solutions_attributes[1][video]": secondVideo,
                "solutions_attributes[1][image]": secondImage,
                "target_audience[gender]": optionData.targetAudience[0],
                "target_audience[age_category]": optionData.targetAudience[1],
                "target_audience[hh_income]": optionData.targetAudience[2],
                "target_audience[education_level]": optionData.targetAudience[3],
                "target_audience[life_style]": optionData.targetAudience[4],
                "target_audience[relationship_status]": optionData.targetAudience[5],
                "target_audience[life_stage]": optionData.targetAudience[6],
                "target_audience[home_ownership]": optionData.targetAudience[7],
            ]
        case 3:
            var firstVideo = Data()
            var firstImage = Data()
            var secondVideo = Data()
            var secondImage = Data()
            var thirdVideo = Data()
            var thirdImage = Data()
            
            if let video = optionData.solutions[0].videoData {
                firstVideo = video
            }
            
            if let image = optionData.solutions[0].imageData {
                firstImage = image
            }
            
            if let video = optionData.solutions[1].videoData {
                secondVideo = video
            }
            
            if let image = optionData.solutions[1].imageData {
                secondImage = image
            }
            
            if let video = optionData.solutions[2].videoData {
                thirdVideo = video
            }
            
            if let image = optionData.solutions[2].imageData {
                thirdImage = image
            }
            
            parameters = [
                "title": optionData.problem!,
                "status": "open",
                "max_participants_count": optionData.respondentsCount!,
                "cost_per_user": "10",
                //                "total_price": Double(optionData.respondentsCount!)! * 10,
                "survey_type": optionData.type!,
                "questions_attributes[0][content]": optionData.problem!,
                "solutions_attributes[0][content]": optionData.solutions[0].content,
                "solutions_attributes[0][video]": firstVideo,
                "solutions_attributes[0][image]": firstImage,
                "solutions_attributes[1][content]": optionData.solutions[1].content,
                "solutions_attributes[1][video]": secondVideo,
                "solutions_attributes[1][image]": secondImage,
                "solutions_attributes[2][content]": optionData.solutions[2].content,
                "solutions_attributes[2][video]": thirdVideo,
                "solutions_attributes[2][image]": thirdImage,
                "target_audience[gender]": optionData.targetAudience[0],
                "target_audience[age_category]": optionData.targetAudience[1],
                "target_audience[hh_income]": optionData.targetAudience[2],
                "target_audience[education_level]": optionData.targetAudience[3],
                "target_audience[life_style]": optionData.targetAudience[4],
                "target_audience[relationship_status]": optionData.targetAudience[5],
                "target_audience[life_stage]": optionData.targetAudience[6],
                "target_audience[home_ownership]": optionData.targetAudience[7],
            ]
        case 4:
            var firstVideo = Data()
            var firstImage = Data()
            var secondVideo = Data()
            var secondImage = Data()
            var thirdVideo = Data()
            var thirdImage = Data()
            var fourthVideo = Data()
            var fourthImage = Data()
            
            if let video = optionData.solutions[0].videoData {
                firstVideo = video
            }
            
            if let image = optionData.solutions[0].imageData {
                firstImage = image
            }
            
            if let video = optionData.solutions[1].videoData {
                secondVideo = video
            }
            
            if let image = optionData.solutions[1].imageData {
                secondImage = image
            }
            
            if let video = optionData.solutions[2].videoData {
                thirdVideo = video
            }
            
            if let image = optionData.solutions[2].imageData {
                thirdImage = image
            }
            
            if let video = optionData.solutions[3].videoData {
                fourthVideo = video
            }
            
            if let image = optionData.solutions[3].imageData {
                fourthImage = image
            }
            
            parameters = [
                "title": optionData.problem!,
                "status": "open",
                "max_participants_count": optionData.respondentsCount!,
                "cost_per_user": "10",
                //                "total_price": Double(optionData.respondentsCount!)! * 10,
                "survey_type": optionData.type!,
                "questions_attributes[0][content]": optionData.problem!,
                "solutions_attributes[0][content]": optionData.solutions[0].content,
                "solutions_attributes[0][video]": firstVideo,
                "solutions_attributes[0][image]": firstImage,
                "solutions_attributes[1][content]": optionData.solutions[1].content,
                "solutions_attributes[1][video]": secondVideo,
                "solutions_attributes[1][image]": secondImage,
                "solutions_attributes[2][content]": optionData.solutions[2].content,
                "solutions_attributes[2][video]": thirdVideo,
                "solutions_attributes[2][image]": thirdImage,
                "solutions_attributes[3][content]": optionData.solutions[3].content,
                "solutions_attributes[3][video]": fourthVideo,
                "solutions_attributes[3][image]": fourthImage,
                "target_audience[gender]": optionData.targetAudience[0],
                "target_audience[age_category]": optionData.targetAudience[1],
                "target_audience[hh_income]": optionData.targetAudience[2],
                "target_audience[education_level]": optionData.targetAudience[3],
                "target_audience[life_style]": optionData.targetAudience[4],
                "target_audience[relationship_status]": optionData.targetAudience[5],
                "target_audience[life_stage]": optionData.targetAudience[6],
                "target_audience[home_ownership]": optionData.targetAudience[7],
            ]
        default:
            parameters = [
                "title": optionData.problem!,
                "status": "open",
                "max_participants_count": optionData.respondentsCount!,
                "cost_per_user": "10",
                //                "total_price": Double(optionData.respondentsCount!)! * 10,
                "survey_type": optionData.type!,
                "questions_attributes[0][content]": optionData.problem!,
                "target_audience[gender]": optionData.targetAudience[0],
                "target_audience[age_category]": optionData.targetAudience[1],
                "target_audience[hh_income]": optionData.targetAudience[2],
                "target_audience[education_level]": optionData.targetAudience[3],
                "target_audience[life_style]": optionData.targetAudience[4],
                "target_audience[relationship_status]": optionData.targetAudience[5],
                "target_audience[life_stage]": optionData.targetAudience[6],
                "target_audience[home_ownership]": optionData.targetAudience[7],
            ]
        }
        
        
        print("SURVEY TYPE - \(optionData.type!)")

        let url = URL(string: stringUrl)!
        
        upload(multipartFormData: { (multipartFormData) in
            for (key,value) in parameters {
                
                if key.contains("video") {
                    if let val = value as? Data {
                        if val.count != 0 {
                            multipartFormData.append(val, withName: key, fileName: "solutionVideo.mov", mimeType: "video/mov")
                        }
                    }
                }
                if key.contains("image") {
                    if let val = value as? Data {
                        if val.count != 0 {
                            multipartFormData.append(val, withName: key, fileName: "solutionImage.jpeg", mimeType: "image/jpeg")
                        }
                    }
                }
                if let val = value as? String {
                    multipartFormData.append((val).data(using: .utf8)!, withName: key)
                }
                
                
            }
        }, to: url, method: .post, headers: ["Authorization":"Bearer " + USER_TOKEN]) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                    //Print progress
                })
                
                upload.responseJSON { response in
                    print(response)
                    //print response.result
                }
                
            case .failure(let encodingError):
                print(encodingError.localizedDescription)
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
    
    func postStripeToken(token: String, complete: @escaping StripeTokenComplete) {
        
        let stringUrl = STRIPE_TOKEN_POST_URL
        
        var params: Parameters

        let totalCost = Double(optionData.totalCost)! * 100
        
        params = [
            "token": token,
            "amount": totalCost,
            "customer": user.stripeId!
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
//            cardParams.currency = "usd"
            
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
            
            self.postStripeToken(token: self.stripeToken, complete: { (result) in
                if result {
                    self.postSurvey { [unowned self] (result) in
                        if result {
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "congratzVCID") as! CongratzViewController
                            self.present(vc, animated: false) {
                                DispatchQueue.main.async {
                                    sender.isEnabled = true
                                    self.hideIndicator()
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
                            
                            sender.isEnabled = true
                            self.hideIndicator()
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
