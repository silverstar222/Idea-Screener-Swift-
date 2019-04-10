//
//  MyIdeasCollectionViewCell.swift
//  Idea Screener
//
//  Created by Silver on 04.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire

class MyIdeasCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var surveysTableView: UITableView!
    
    var delegate:profileVCDelegate!
    
    var surveys = [Survey]()
    
    var errorsArray = [String()]
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        getSurveys { [unowned self] (result) in
            if result {
                self.surveysTableView.reloadData()
            } else {
                
                var errorList = ""
                for error in self.errorsArray {
                    errorList = errorList + error + "\n"
                }
                
                if self.errorsArray.contains("Signature has expired") || self.errorsArray.contains("Signature verification raised") || self.errorsArray.contains("Not enough or too many segments") {
                    DispatchQueue.main.async {
                        let profileVC = self.delegate.getVC()
                        TokenHandler.shared.showLoginAlert(vc: profileVC)
                    }
                    
                } else {
                    let alert = UIAlertController(title: "Error", message: errorList, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    let profileVC = self.delegate.getVC()
                    
                    profileVC.present(alert, animated: true, completion: {
                        self.errorsArray.removeAll()
                    })
                }
                
            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyCell", for: indexPath) as! SurveyTableViewCell
        
        let survey = surveys[indexPath.row]
        
        cell.questionTextView.text = survey.title
        
        cell.totalCostLabel.text = "$\(survey.totalCost!)"
        cell.totalRespondersLabel.text = String(survey.maxParticipantsCount)
        if let respondentsCount = survey.respondentsCount {
            cell.currentRespondersLabel.text = String(respondentsCount)
        } else {
            cell.currentRespondersLabel.text = "0"
        }
        
        switch survey.status {
        case "open":
            cell.statusLabel.text = "OPEN"
            cell.statusView.backgroundColor = #colorLiteral(red: 0, green: 0.7618721128, blue: 0.3824557662, alpha: 1)
        case "closed":
            cell.statusLabel.text = "CLOSED"
            cell.statusView.backgroundColor = .red
            cell.totalRespondersLabel.isHidden = true
            cell.totalRespondersImageView.isHidden = true
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let survey = surveys[indexPath.row]
        
        if(self.delegate != nil){ //Just to be safe.
            self.delegate.selectedCell(withOption: survey.type, data: survey)
        }
        
    }
    
    
    func getSurveys(complete: @escaping DownloadComplete) {
        
        let stringUrl = SURVEYS_URL
        
        let url = URL(string: stringUrl)!
        
        print("URL - " + stringUrl)
        
        request(url, method: .get, parameters: nil, encoding: JSONEncoding() as ParameterEncoding, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    if let data: Array<Dictionary<String,Any>> = object["data"] as? Array {
                        
                        if data.count > 0 {
                            
                            for item in data {
                                
                                let survey = Survey()
    
                                if let id = item["id"] as? String {
                                    survey.id = id
                                }
                                
                                if let attributes: Dictionary<String,Any> = item["attributes"] as? Dictionary {
                                    
                                    if let status = attributes["status"] as? String {
                                        survey.status = status
                                    }
                                    
                                    if let title = attributes["title"] as? String {
                                        survey.title = title
                                    }
                                    
                                    if let totalPrice = attributes["total-price"] as? String {
                                        survey.totalCost = totalPrice
                                    }
                                    
                                    if let costPerUser = attributes["cost-per-user"] as? String {
                                        survey.costPerUser = costPerUser
                                    }
                                    
                                    if let maxParticipantsCount = attributes["max-participants-count"] as? Int {
                                        survey.maxParticipantsCount = maxParticipantsCount
                                    }
                                    
                                    if let respondentsCount = attributes["respondents-count"] as? Int {
                                        survey.respondentsCount = respondentsCount
                                    }

                                    
                                    
                                    if let targetAudience: Dictionary<String,Any> = attributes["target-audience"] as? Dictionary {
                                        
                                        var targetAudienceArray = ["","","","","","","",""]
                                        
                                        if let gender = targetAudience["gender"] as? String {
                                            targetAudienceArray[0] = gender
                                        }
                                        
                                        if let age = targetAudience["age-category"] as? String {
                                            targetAudienceArray[1] = age
                                        }
                                        
                                        if let income = targetAudience["hh-income"] as? String {
                                            targetAudienceArray[2] = income
                                        }
                                        
                                        if let educationLevel = targetAudience["education-level"] as? String {
                                            targetAudienceArray[3] = educationLevel
                                        }
                                        
                                        if let lifeStyle = targetAudience["life-style"] as? String {
                                            targetAudienceArray[4] = lifeStyle
                                        }
                                        
                                        if let relationshipStatus = targetAudience["relationship-status"] as? String {
                                            targetAudienceArray[5] = relationshipStatus
                                        }
                                        
                                        if let lifeStage = targetAudience["life-stage"] as? String {
                                            targetAudienceArray[6] = lifeStage
                                        }
                                        
                                        if let homeOwnership = targetAudience["home-ownership"] as? String {
                                            targetAudienceArray[7] = homeOwnership
                                        }
                                        
                                        survey.targetAudience = targetAudienceArray
                                        
                                    }
                                    
                                    if let surveyType = attributes["survey-type"] as? String {
                                        
                                        print("SURVEY TYPE - \(surveyType)")
                                        switch surveyType {
                                        case "single_question":
                                            survey.type = "Single"
                                        case "multiple_question":
                                            survey.type = "Multiple"
                                        case "test_multiple_question":
                                            survey.type = "TestMultiple"
                                        default:
                                            survey.type = ""
                                        }
                                    }
                                    
                                }
                                
                                self.surveys.append(survey)
                            }
                            

                            
                        }

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
    
    
    
    
    
    
}
