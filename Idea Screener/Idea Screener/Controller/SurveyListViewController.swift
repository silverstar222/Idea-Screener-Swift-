//
//  SurveyListViewController.swift
//  Idea Screener
//
//  Created by Silver on 26.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire

class SurveyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var surveysTableView: UITableView!

    var surveys = [Survey]()
    
    var errorsArray = [String()]

    override func viewDidLoad() {
        super.viewDidLoad()

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
        return surveys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyCell", for: indexPath) as! SurveyTableViewCell
        
        let survey = surveys[indexPath.row]
        
        cell.totalCostLabel.text = survey.totalCost
        cell.questionTextView.text = survey.title
        cell.totalRespondersLabel.text = String(survey.maxParticipantsCount)
        cell.statusLabel.text = survey.status
        
        return cell
    }
    
    
    func getSurveys(complete: @escaping DownloadComplete) {
        
        let stringUrl = GET_AVAIBLE_SURVEYS
        
        let url = URL(string: stringUrl)!
        
        print("URL - " + stringUrl)
        
        request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {

                    if let data: Array<Dictionary<String,Any>> = object["data"] as? Array {

                        if data.count > 0 {

                            let survey = Survey()

                            for item in data {
                                
                                
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
                                    
                                    if let cost = attributes["cost-per-user"] as? String {
                                        var doubleCost = Double(cost)
                                        doubleCost = doubleCost! / 2
                                        survey.totalCost = "$" + String(doubleCost!)
                                    }
                                    
                                    if let maxCount = attributes["max-participants-count"] as? Int {
                                        survey.maxParticipantsCount = maxCount
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
                                
                            }


                            self.surveys.append(survey)


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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
