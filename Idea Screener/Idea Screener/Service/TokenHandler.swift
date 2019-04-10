//
//  tokenHandler.swift
//  Idea Screener
//
//  Created by Silver on 26.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire


class TokenHandler: NSObject{
    static let shared = TokenHandler()
    fileprivate var currentVC: UIViewController?
    
    fileprivate var context = CoreDataManager.instance.persistentContainer.viewContext
    fileprivate var errorsArray = [String()]
    fileprivate var user = User()
    fileprivate let group = DispatchGroup()

    
    
    
    func showLoginAlert(vc: UIViewController) {
        currentVC = vc
        let alert = UIAlertController(title: "Signature has expired!", message: "Please, login again.", preferredStyle: .alert)
        
        alert.addTextField { (emailTextField) in
            
            emailTextField.placeholder = "Email"
            emailTextField.keyboardType = UIKeyboardType.emailAddress
            emailTextField.text = CURRENT_USER_EMAIL
            
        }
        
        alert.addTextField { (passwordTextField) in
            passwordTextField.placeholder = "Password"
            passwordTextField.keyboardType = UIKeyboardType.default
            passwordTextField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            
            let emailTextField = alert.textFields?.first
            let passwordTextField = alert.textFields?.last
            
            self.performLogin(email: (emailTextField?.text)!, password: (passwordTextField?.text)!, complete: { (result) in
                if result {
                    // Save the context.
                    do {
                        try self.context.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    
                    CURRENT_USER_EMAIL = (emailTextField?.text)!
                    CURRENT_USER_ID = String(self.user.id)
                    vc.navigationController?.popToRootViewController(animated: true)
                    
                } else {
                    
                    var errorList = ""
                    for error in self.errorsArray {
                        errorList = errorList + error + "\n"
                    }
                    
                    let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    vc.present(alert, animated: true, completion: {
                        self.errorsArray.removeAll()
                    })
                    
                }
                
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(alert, animated: true, completion: {
            
        })
        
    }
    
    fileprivate func getUser() -> User? {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        if (UserDefaults.standard.object(forKey: .keyForUserPredicate) as? String) != nil {
            userFetchRequest.predicate = NSPredicate(format: "email == %@", CURRENT_USER_EMAIL)
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
    
    private func performLogin(email: String, password: String, complete: @escaping LoginComplete){
        
        let stringUrl = LOGIN_URL
        
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]
        
        let url = URL(string: stringUrl)!
        
        request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(contentType: ["application/json"]).responseJSON { (response) in
            
            switch response.result {
            case .success(let data):
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
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
                    
                    if let accessToken = object["access_token"] as? String {
                        aToken = accessToken
                    }
                    
                    if let user = self.getUser() {
                        user.usertoken = aToken
                        USER_TOKEN = aToken
                    } else {
                        self.group.enter()
                        self.getUserProfile(newToken: aToken, complete: { (result,userStruct) in
                            if result == true {
                                self.createUser(name: userStruct?.name, email: userStruct?.email, password: password, userCreatedAt: userStruct?.userCreatedAt, ageCategory: userStruct?.ageCategory, bio: userStruct?.bio, birthDate: userStruct?.birthDate, profileCreatedAt: userStruct?.profileCreatedAt, educationLevel: userStruct?.educationLevel, firstName: userStruct?.firstName, gender: userStruct?.gender, hhIncome: userStruct?.hhIncome, homeOwnership: userStruct?.homeOwnership, profileId: (userStruct?.profileId)!, isCompleted: (userStruct?.isCompleted)!, lastName: userStruct?.lastName, lifeStage: userStruct?.lifeStage, lifeStyle: userStruct?.lifeStyle, relationshipStatus: userStruct?.relationshipStatus, profileUpdatedAt: userStruct?.profileUpdatedAt, userId: (userStruct?.userId)!, accessToken: aToken)
                                
                                USER_TOKEN = aToken
                                
                            }
                            self.group.leave()

                        })
                        
                       self.group.wait()

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
    
    fileprivate func getUserProfile(newToken: String, complete: @escaping UserProfileComplete) {
        
        let stringUrl = PROFILE_URL
        
        let url = URL(string: stringUrl)!
        
        request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":"Bearer " + newToken]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            let userStuct = UserStruct()
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    
                    if let email = object["email"] as? String {
                        userStuct.email = email
                    }
                    if let name = object["name"] as? String {
                        userStuct.name = name
                    }
                    if let userCreatedAt = object["created_at"] as? String {
                        userStuct.userCreatedAt = userCreatedAt
                    }
                    if let userId = object["user_id"] as? Int {
                        userStuct.userId = userId
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
            
        }
        
        
    }
    
    fileprivate func createUser(name: String?, email: String?, password:String?, userCreatedAt:String?, ageCategory:String?, bio:String?, birthDate:String?, profileCreatedAt:String?, educationLevel:String?, firstName:String?, gender:String?, hhIncome:String?, homeOwnership:String?, profileId:Int, isCompleted:Bool, lastName:String?, lifeStage:String?, lifeStyle:String?, relationshipStatus: String?, profileUpdatedAt:String?, userId:Int, accessToken: String){
        
        let user = User(context: context)
        
        user.name = name
        user.email = email
        user.password = password
        user.usertoken = accessToken
        user.createdAt = userCreatedAt
        user.ageCategory = ageCategory
        user.bio = bio
        user.birthDate = birthDate
        user.profileCreatedAt = profileCreatedAt
        user.educationLevel = educationLevel
        user.firstName = firstName
        user.gender = gender
        user.hhIncome = hhIncome
        user.homeOwnership = homeOwnership
        user.profileId = Int32(profileId)
        user.isCompleted = isCompleted
        user.lastName = lastName
        user.lifeStage = lifeStage
        user.lifeStyle = lifeStyle
        user.relationshipStatus = relationshipStatus
        user.profileUpdatedAt = profileUpdatedAt
        user.id = Int32(userId)
        
        
        
        
    }
    
    
    
    
}

