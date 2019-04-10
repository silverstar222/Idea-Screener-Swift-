//
//  ProfileViewController.swift
//  Idea Screener
//
//  Created by Silver on 04.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


protocol profileVCDelegate {
    func getVC() -> UIViewController
    
    func selectedCell(withOption: String, data: Survey?)
    
    func getUser() -> User
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, profileVCDelegate, UITextFieldDelegate {
 
    @IBOutlet weak var profilePhotoBtn: DesignableButton!
    
    @IBOutlet weak var profileImageView: DesignableImageView!
   
    @IBOutlet weak var blurImageView: UIImageView!
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    @IBOutlet weak var myIdeasBtn: UIButton!
    
    @IBOutlet weak var respondedIdeasBtn: UIButton!
    
    @IBOutlet weak var sliderView: UIView!
        
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    
    var profileImage: UIImage!
    
    let userPhotoHandler = UserPhotoHandler.shared
    
    let context = CoreDataManager.instance.persistentContainer.viewContext
    
    var errorsArray = [String()]
    
    var user: User!
    
    var savedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fUser = fetchUser() {
            user = fUser
            
            CURRENT_USER_ID = String(self.user.id)
            
            if let profileImageUrl = user.imageUrl {
                let url = URL(string: profileImageUrl)
                if url != nil {
                    downloadImage(url: url!)
                    
                } else {
                    print("Wrong profile image url!")
                }
            } else {
                profilePhotoBtn.setImage(UIImage(), for: .normal)
                profileImageView.image = #imageLiteral(resourceName: "ic_add_user_pic")
            }
            
            userNameTextField.text = user.name
            userEmailLabel.text = user.email
            
        }
        
        self.hideKeyboardWhenTappedAround()

        
        btTap(myIdeasBtn)

    }
    
    deinit {
        
        if let collectionCell = profileCollectionView.cellForItem(at: IndexPath(row: 1, section: 0)) as? ScreenedIdeasCollectionViewCell {
            
            let respondedSurveys = collectionCell.respondedSurveys
            
            if respondedSurveys.count > 0 {
                
                for i in 0...respondedSurveys.count-1 {
                    if let optionCell = collectionCell.screenedIdeasTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? RespondedIdeaTableViewCell {
                        if respondedSurveys[i].solutionVideo != nil {
                            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: optionCell.optionPlayerView.player?.currentItem)

                        }
                    }
                }
            }
        }
  
  
        print("deinited")
        
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profileImageView.image = UIImage(data: data)
                self.blurImageView.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func updateProfileImage(image: Data, complete: @escaping ImageUpdateComplete) {
        
        var parameters: Parameters

        parameters = [
            "image": image,
        ]
        
        let stringUrl = PROFILE_UPDATE_URL
        
        let url = URL(string: stringUrl)!
        
        upload(multipartFormData: { (multipartFormData) in
            for (key,value) in parameters {
                
                multipartFormData.append(value as! Data, withName: key, fileName: "profileImage.jpeg", mimeType: "image/jpeg")
                
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
                
                //print encodingError.description
            }
            
            complete(true)
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileCollectionView.collectionViewLayout.invalidateLayout()
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
    @IBAction func profilePhotoBtnTap(_ sender: DesignableButton) {
        userPhotoHandler.showAttachmentActionSheet(vc: self)
        
        DispatchQueue.main.async { [unowned self] in
            self.userPhotoHandler.showAttachmentActionSheet(vc: self)
            self.userPhotoHandler.imagePickedBlock = { (image) in
                
                let imgData = UIImageJPEGRepresentation(image, 0.3)!
                
                let dataSize = Double(imgData.count) / (1024*1024)
                print("DataSize = \(dataSize) MB")
                
                if dataSize > 20 {
                    let alert = UIAlertController(title: "Error", message: "Image size is too big (20 MB max)!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(alertAction)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                
                sender.isEnabled = false
                self.updateProfileImage(image: imgData, complete: { (result) in
                    sender.isEnabled = true

                    if result {
                        self.profileImageView.image = image
                        self.blurImageView.image = image
                        
                    }
                })
                
            }
            
        }
        
        
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func myIdeasBtnTap(_ sender: UIButton) {
        btTap(sender)
    }
    
    @IBAction func respondedIdeasBtnTap(_ sender: UIButton) {
        btTap(sender)
    }
    
    @IBAction func editProfileNameBtnTap(_ sender: UIButton) {
        userNameTextField.isEnabled = true
        userNameTextField.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case userNameTextField:
            savedText = userNameTextField.text!
            userNameTextField.text = ""
            
        default:
            return
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case userNameTextField:
            
            performNameUpdate { (result) in
                self.userNameTextField.isEnabled = false
                
                if result {
                    self.user.name = self.userNameTextField.text!
                    // Save the context.
                    do {
                        try self.context.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    
                    let alert = UIAlertController(title: nil, message: "Name has been changed!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    self.userNameTextField.text = self.savedText
                    
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
            
        default:
            return
        }
    }
    
    func performNameUpdate(complete: @escaping UserUpdateComplete) {
        
        let stringUrl = USER_UPDATE_URL
        
        if (userNameTextField.text?.count)! < 3 {
            
            self.errorsArray.append("Name is too short (minimum is 3 characters)")
            
            complete(false)
            return
        }
        
        if (userNameTextField.text?.count)! > 30 {
            
            self.errorsArray.append("Name is too long (maximum is 30 characters)")
            
            complete(false)
            return
        }
        
        let parameters: Parameters = [
            
            "name": userNameTextField.text!,
            
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
                    
                    if let name: Array<String> = object["name"] as? Array {
                        
                        for error in name {
                            self.errorsArray.append("New name " + error)
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
            return
            
        }
        
        
    }
    
    
    func btTap(_ btTap: UIButton) {
        switch btTap {
        case myIdeasBtn:
            profileCollectionView.scrollToItem(at: IndexPath(row: 0 , section: 0), at: .left, animated: true)
            myIdeasBtn.isHighlighted = false
            respondedIdeasBtn.isHighlighted = true
            
            UIView.animate(withDuration: 0.3) {
                self.sliderView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            
        case respondedIdeasBtn:
            profileCollectionView.scrollToItem(at: IndexPath(row: 1 , section: 0), at: .left, animated: true)
            myIdeasBtn.isHighlighted = true
            respondedIdeasBtn.isHighlighted = false
            
            UIView.animate(withDuration: 0.3) {
                self.sliderView.transform = CGAffineTransform(translationX: self.sliderView.frame.size.width, y: 0)
            }
            
        default:
            print("HZ")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "profileMyIdeasCell", for: indexPath) as! MyIdeasCollectionViewCell
            
            cell.delegate = self
            
            return cell
        case 1:
            let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "profileScreenedIdeasCell", for: indexPath) as! ScreenedIdeasCollectionViewCell
            
            cell.delegate = self

            return cell
        default:
            print("hz")
        }
        
        return UICollectionViewCell()

    }
    
    // MARK: - Profile VC Delegates
    
    func selectedCell(withOption: String, data: Survey?) {
        
        switch withOption {
        case "Single":
            self.performSegue(withIdentifier: "SingleReportSegue", sender: data)
        case "Multiple":
            self.performSegue(withIdentifier: "MultipleReportSegue", sender: data)
        case "TestMultiple":
            self.performSegue(withIdentifier: "TestMultipleReportSegue", sender: data)
        case "GotoSurveyListSegue":
            self.performSegue(withIdentifier: "GotoSurveyListSegue", sender: nil)
        case "GotoGetStartedSegue":
            self.performSegue(withIdentifier: "GotoGetStartedSegue", sender: nil)
        case "GotoResponderTutorialSegue":
            self.performSegue(withIdentifier: "GotoResponderTutorialSegue", sender: nil)
        default:
            return
        }
    }
    
    func getVC() -> UIViewController {
        return self
    }
    
    func getUser() -> User {
        return user
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: profileCollectionView.frame.size.width, height: profileCollectionView.frame.size.height)
    }
    

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SingleReportSegue" {
            if let singleOptionReportViewController = segue.destination as? SingleOptionReportViewController {
                if let survey = sender as? Survey {
                    singleOptionReportViewController.survey = survey
                }
            }
        }
        if segue.identifier == "MultipleReportSegue" {
            if let multipleOptionReportViewController = segue.destination as? MultipleOptionReportViewController {
                if let survey = sender as? Survey {
                    multipleOptionReportViewController.survey = survey
                }
            }
        }
        if segue.identifier == "TestMultipleReportSegue" {
            if let testMultipleOptionReportViewController = segue.destination as? TestMultipleOptionReportViewController {
                if let survey = sender as? Survey {
                    testMultipleOptionReportViewController.survey = survey
                }
            }
        }
    }

}
