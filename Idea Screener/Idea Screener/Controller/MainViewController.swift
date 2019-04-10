//
//  MainViewController.swift
//  Idea Screener
//
//  Created by Silver on 23.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class MainViewController: UIViewController {
    
    @IBOutlet weak var smbIdeaBtn: UIButton!
    
    @IBOutlet weak var becomeResponderBtn: UIButton!
    
    @IBOutlet weak var profileBtn: UIBarButtonItem!
    
    let context = CoreDataManager.instance.persistentContainer.viewContext
    
    var user: User!
    
    var errorsArray = [String()]
    
    var profileChecked = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getUserProfile { [unowned self] (result, userStruct) in
            
            if result == true {
                
                if let userStr = userStruct {
                    self.user.ageCategory = userStr.ageCategory
                    self.user.createdAt = userStr.userCreatedAt
                    self.user.email = userStr.email
                    self.user.bio = userStr.bio
                    self.user.birthDate = userStr.birthDate
                    self.user.educationLevel = userStr.educationLevel
                    self.user.firstName = userStr.firstName
                    self.user.lastName = userStr.lastName
                    self.user.gender = userStr.gender
                    self.user.hhIncome = userStr.hhIncome
                    self.user.homeOwnership = userStr.homeOwnership
                    if let userId = userStr.userId {
                        self.user.id = Int32(userId)
                    }
                    if let completed = userStr.isCompleted {
                        self.user.isCompleted = completed
                    }
                    self.user.lifeStage = userStr.lifeStage
                    self.user.lifeStyle = userStr.lifeStyle
                    self.user.name = userStr.name
                    self.user.profileCreatedAt = userStr.profileCreatedAt
                    self.user.profileUpdatedAt = userStr.profileUpdatedAt
                    if let profileId = userStr.profileId {
                        self.user.profileId = Int32(profileId)
                    }
                    self.user.relationshipStatus = userStr.relationshipStatus
                    self.user.imageUrl = userStr.imageStringUrl
                    self.user.stripeId = userStr.stripeId
                    
                    print(self.user)
                    
                    print("user id - " + CURRENT_USER_ID)
                    print("user email - " + CURRENT_USER_EMAIL)
                    
                    if notificationStart {
                        
                        if self.user.isCompleted {
                            
                            switch respondSurvey.type {
                            case "single_question":
                                self.performSegue(withIdentifier: "GotoSingleOptionResponse", sender: nil)
                            case "multiple_question":
                                self.performSegue(withIdentifier: "GotoMultipleOptionResponse", sender: nil)
                            case "test_multiple_question":
                                self.performSegue(withIdentifier: "GotoTestMultipleOptionResponse", sender: nil)
                            default:
                                print("hz")
                                
                            }
                            
                        } else {
                            print("User profile is not completed")
                            let alert = UIAlertController(title: "Error", message: "User profile is not completed", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: {})
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
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fUser = fetchUser() {
            user = fUser
            
        }
        
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
    
    func getUserProfile(complete: @escaping UserProfileComplete) {
        
        let stringUrl = PROFILE_URL
        
        let url = URL(string: stringUrl)!
        
        request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            let userStuct = UserStruct()
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    
                    if let email = object["email"] as? String {
                        print(email)
                        userStuct.email = email
                    }
                    if let name = object["name"] as? String {
                        print(name)
                        userStuct.name = name
                    }
                    if let userCreatedAt = object["created_at"] as? String {
                        userStuct.userCreatedAt = userCreatedAt
                    }
                    if let userId = object["user_id"] as? Int {
                        userStuct.userId = userId
                        CURRENT_USER_ID = String(userId)
                    }
                    
                    if let stripeId = object["stripe_id"] as? String {
                        userStuct.stripeId = stripeId
                    }
                    
                    if let profile:Dictionary<String,Any> = object["profile"] as? Dictionary {
                        
                        if let ageCategory = profile["age_category"] as? String {
                            userStuct.ageCategory = ageCategory
                        }
                        if let bio = profile["bio"] as? String {
                            userStuct.bio = bio
                        }
                        if let birthDate = profile["birth_date"] as? String {
                            userStuct.birthDate = birthDate
                        }
                        if let profileCreatedAt = profile["created_at"] as? String {
                            userStuct.profileCreatedAt = profileCreatedAt
                        }
                        if let educationLevel = profile["education_level"] as? String {
                            userStuct.educationLevel = educationLevel
                        }
                        if let firstName = profile["first_name"] as? String {
                            userStuct.firstName = firstName
                        }
                        if let gender = profile["gender"] as? String {
                            userStuct.gender = gender
                        }
                        if let hhIncome = profile["hh_income"] as? String {
                            userStuct.hhIncome = hhIncome
                        }
                        if let homeOwnership = profile["home_ownership"] as? String {
                            userStuct.homeOwnership = homeOwnership
                        }
                        if let isCompleted = profile["is_completed"] as? Bool {
                            userStuct.isCompleted = isCompleted
                        }
                        if let lastName = profile["last_name"] as? String {
                            userStuct.lastName = lastName
                        }
                        if let lifeStage = profile["life_stage"] as? String {
                            userStuct.lifeStage = lifeStage
                        }
                        if let lifeStyle = profile["life_style"] as? String {
                            userStuct.lifeStyle = lifeStyle
                        }
                        if let relationshipStatus = profile["relationship_status"] as? String {
                            userStuct.relationshipStatus = relationshipStatus
                        }
                        if let profileUpdatedAt = profile["updated_at"] as? String {
                            userStuct.profileUpdatedAt = profileUpdatedAt
                        }
                        if let userProfileImage: Dictionary<String,Any> = profile["image"] as? Dictionary {
                            if let url = userProfileImage["url"] as? String {
                                userStuct.imageStringUrl = url
                            }
                        }
                        
                        
                    }
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        complete(false,nil)
                        return
                        
                    }
                    
                }
                
            case .failure(let error):
                self.errorsArray.append(error.localizedDescription)
                complete(false,nil)
                return
            }
            
            complete(true, userStuct)
            return
            
        }
        
        
    }
    
    @IBAction func smbIdeaBtnTap(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        getUserProfile { [unowned self] (result, userStruct) in
            sender.isEnabled = true

            if result == true {
                
                if let userStr = userStruct {
                    self.user.ageCategory = userStr.ageCategory
                    self.user.createdAt = userStr.userCreatedAt
                    self.user.bio = userStr.bio
                    self.user.birthDate = userStr.birthDate
                    self.user.educationLevel = userStr.educationLevel
                    self.user.firstName = userStr.firstName
                    self.user.lastName = userStr.lastName
                    self.user.gender = userStr.gender
                    self.user.hhIncome = userStr.hhIncome
                    self.user.homeOwnership = userStr.homeOwnership
                    if let userId = userStr.userId {
                        self.user.id = Int32(userId)
                    }
                    if let completed = userStr.isCompleted {
                        self.user.isCompleted = completed
                    }
                    self.user.lifeStage = userStr.lifeStage
                    self.user.lifeStyle = userStr.lifeStyle
                    self.user.name = userStr.name
                    self.user.profileCreatedAt = userStr.profileCreatedAt
                    self.user.profileUpdatedAt = userStr.profileUpdatedAt
                    if let profileId = userStr.profileId {
                        self.user.profileId = Int32(profileId)
                    }
                    self.user.relationshipStatus = userStr.relationshipStatus
                    self.user.imageUrl = userStr.imageStringUrl
                    
                    print("user id - " + CURRENT_USER_ID)
                    
                    if let tutorialBool = UserDefaults.standard.object(forKey: .keyForSmbIdeaTutorial) as? Bool {
                        if tutorialBool == true {
                            self.performSegue(withIdentifier: "GotoSmbIdeaSegue", sender: nil)
                        }
                    } else {
                        self.performSegue(withIdentifier: "GotoSmbIdeaTutorialSegue", sender: nil)
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
            
            
        }
        

    }
    
    @IBAction func profileBtnTap(_ sender: UIBarButtonItem) {
        sender.isEnabled = false

        getUserProfile { [unowned self] (result, userStruct) in
            sender.isEnabled = true

            if result == true {
                
                if let userStr = userStruct {
                    self.user.ageCategory = userStr.ageCategory
                    self.user.createdAt = userStr.userCreatedAt
                    self.user.bio = userStr.bio
                    self.user.birthDate = userStr.birthDate
                    self.user.educationLevel = userStr.educationLevel
                    self.user.firstName = userStr.firstName
                    self.user.lastName = userStr.lastName
                    self.user.gender = userStr.gender
                    self.user.hhIncome = userStr.hhIncome
                    self.user.homeOwnership = userStr.homeOwnership
                    if let userId = userStr.userId {
                        self.user.id = Int32(userId)
                    }
                    if let completed = userStr.isCompleted {
                        self.user.isCompleted = completed
                    }
                    self.user.lifeStage = userStr.lifeStage
                    self.user.lifeStyle = userStr.lifeStyle
                    self.user.name = userStr.name
                    self.user.profileCreatedAt = userStr.profileCreatedAt
                    self.user.profileUpdatedAt = userStr.profileUpdatedAt
                    if let profileId = userStr.profileId {
                        self.user.profileId = Int32(profileId)
                    }
                    self.user.relationshipStatus = userStr.relationshipStatus
                    self.user.imageUrl = userStr.imageStringUrl
                    
                    print("user id - " + CURRENT_USER_ID)

                    self.performSegue(withIdentifier: "GotoProfile", sender: nil)
                }
                
            } else {
                
                var errorList = ""
                for error in self.errorsArray {
                    errorList = errorList + error + "\n"
                }
                
                if self.errorsArray.contains("Signature has expired") || self.errorsArray.contains("Signature verification raised") || self.errorsArray.contains("Not enough or too many segments") {
                    print("yeboi")
                    DispatchQueue.main.async {
                        print("yeboi2")
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
    
    
    @IBAction func responderBtnTap(_ sender: UIButton) {
        sender.isEnabled = false

        getUserProfile { [unowned self] (result, userStruct) in
            sender.isEnabled = true

            if result == true {
                
                if let userStr = userStruct {
                    self.user.ageCategory = userStr.ageCategory
                    self.user.createdAt = userStr.userCreatedAt
                    self.user.bio = userStr.bio
                    self.user.birthDate = userStr.birthDate
                    self.user.educationLevel = userStr.educationLevel
                    self.user.firstName = userStr.firstName
                    self.user.lastName = userStr.lastName
                    self.user.gender = userStr.gender
                    self.user.hhIncome = userStr.hhIncome
                    self.user.homeOwnership = userStr.homeOwnership
                    if let userId = userStr.userId {
                        self.user.id = Int32(userId)
                    }
                    if let completed = userStr.isCompleted {
                        self.user.isCompleted = completed
                    }
                    self.user.lifeStage = userStr.lifeStage
                    self.user.lifeStyle = userStr.lifeStyle
                    self.user.name = userStr.name
                    self.user.profileCreatedAt = userStr.profileCreatedAt
                    self.user.profileUpdatedAt = userStr.profileUpdatedAt
                    if let profileId = userStr.profileId {
                        self.user.profileId = Int32(profileId)
                    }
                    self.user.relationshipStatus = userStr.relationshipStatus
                    self.user.imageUrl = userStr.imageStringUrl
                    
                    print("user id - " + CURRENT_USER_ID)

                    if self.user.isCompleted {
                        
                        let alert = UIAlertController(title: "You have already become a responder", message: nil, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
//                            self.performSegue(withIdentifier: "GotoSurveyListSegue", sender: nil)
                        })
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        if let tutorialBool = UserDefaults.standard.object(forKey: .keyForResponderTutorial) as? Bool {
                            if tutorialBool == true {
                                self.performSegue(withIdentifier: "GotoResponderSegue", sender: nil)
                            }
                        } else {
                            self.performSegue(withIdentifier: "GotoResponderTutorialSegue", sender: nil)
                        }
                        
                    }
                }
                
            } else {
                
                var errorList = ""
                for error in self.errorsArray {
                    errorList = errorList + error + "\n"
                }
                
                if self.errorsArray.contains("Signature has expired") || self.errorsArray.contains("Signature verification raised") || self.errorsArray.contains("Not enough or too many segments") {
                    print("yeboi")
                    DispatchQueue.main.async {
                        print("yeboi2")
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
