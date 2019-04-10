//
//  ScreenedIdeasCollectionViewCell.swift
//  Idea Screener
//
//  Created by Silver on 04.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire

class ScreenedIdeasCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var screenedIdeasTableView: UITableView!
    
    var delegate:profileVCDelegate!
    
    var respondedSurveys = [RespondedSurvey]()
    
    var errorsArray = [String()]
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        getSurveys { [unowned self] (result) in
            if result {
                self.screenedIdeasTableView.reloadData()
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
        
        if respondedSurveys.count == 0 {
            return 1
        } else {
            return respondedSurveys.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if respondedSurveys.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noIdeaScreensCell", for: indexPath) as! NoIdeaScreensTableViewCell
            
            cell.getStartedBtn.addTarget(self, action: #selector(gotoSegue(_:)), for: .touchUpInside)
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RespondedIdeaCell", for: indexPath) as! RespondedIdeaTableViewCell
            
            let survey = respondedSurveys[indexPath.row]
            
            cell.costLabel.text = "$" + survey.cost
            cell.problemTextView.text = survey.title
            if let date = survey.date {
                cell.dateLabel.text = formatteDate(stringDate: date)
            }
            cell.typeLabel.text = survey.type
            
            if let content = survey.solutionContent {
                cell.optionTextView.text = content
            }
            
            if let imageStringUrl = survey.solutionImageStringUrl {
                
                if let url = URL(string: imageStringUrl) {
                    cell.optionImageView.downloadedFrom(url: url)
                    cell.optionImageView.isHidden = false
                }
                
            }
            
            if let video = survey.solutionVideo {
                
                cell.optionPlayerView.playerLayer.player = video
                cell.optionPlayerView.isHidden = false
                if cell.optionPlayerView.isHidden == false {
                    cell.playBtn.tag = indexPath.row
                    cell.playBtn.addTarget(self, action: #selector(playVideoBtnTap(_:)), for: .touchUpInside)
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: cell.optionPlayerView.player?.currentItem, queue: .main) { _ in
                        cell.optionPlayerView.player?.seek(to: kCMTimeZero)
                        cell.optionPlayerView.player?.pause()
                        cell.videoIsPlaying = false
                        cell.playBtn.setImage(#imageLiteral(resourceName: "img_play_btn"), for: .normal)
                        
                    }
                    
                }
                
                
            }
            
            return cell
        }
        
    }

    
    
    @objc func playVideoBtnTap(_ sender: UIButton) {
        if let optionCell = screenedIdeasTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? RespondedIdeaTableViewCell {
            
            if optionCell.videoIsPlaying == false {
                optionCell.optionPlayerView.player?.play()
                optionCell.videoIsPlaying = true
                optionCell.playBtn.setImage(UIImage(), for: .normal)
            } else {
                optionCell.optionPlayerView.player?.pause()
                optionCell.videoIsPlaying = false
                optionCell.playBtn.setImage(#imageLiteral(resourceName: "img_play_btn"), for: .normal)
            }
            
            
            
        }
    }
    
    
    func getSurveys(complete: @escaping DownloadComplete) {

        let stringUrl = RESPONDED_SURVEYS_URL

        let url = URL(string: stringUrl)!

        print("URL - " + stringUrl)

        request(url, method: .get, parameters: nil, encoding: JSONEncoding() as ParameterEncoding, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in

            switch response.result {
            case .success(let data):
                print(data)

                if let object:Dictionary<String,Any> = data as? Dictionary {

                    if let surveys: Array<Dictionary<String,Any>> = object["survey"] as? Array {

                        if surveys.count > 0 {

                            for item in surveys {

                                let survey = RespondedSurvey()

                                if let type = item["type"] as? String {
                                    survey.type = type
                                }
                                
                                if let title = item["title"] as? String {
                                    survey.title = title
                                }
                                
                                if let cost = item["cost_per_user"] as? String {
                                    var doubleCost = Double(cost)!
                                    doubleCost = doubleCost / 2
                                    survey.cost = String(doubleCost)
                                }
                                
                                if let surveyType = item["survey_type"] as? String {
                                    
                                    switch surveyType {
                                    case "single_question":
                                        survey.type = "SINGLE OPTION"
                                    case "multiple_question":
                                        survey.type = "MULTIPLE CHOICE"
                                    case "test_multiple_question":
                                        survey.type = "TEST MULTIPLE OPTIONS"
                                    default:
                                        survey.type = ""
                                    }
                                    
                                }

                                self.respondedSurveys.append(survey)
                            }

                        }

                    }
                    
                    if let date: Array<Dictionary<String,Any>> = object["date"] as? Array {
                        
                        if date.count > 0 {
                            
                            for (index,item) in date.enumerated() {
                                
                                if let date = item["created_at"] as? String {
                                    self.respondedSurveys[index].date = date
                                }
                                
                                if let id = item["survey_id"] as? Int {
                                    self.respondedSurveys[index].id = id
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    if let answeredSolutions: Array<Dictionary<String,Any>> = object["answered_solutions"] as? Array {
                        
                        if answeredSolutions.count > 0 {
                            
                            for solution in answeredSolutions {
                                
                                var surId = 123
                                var solContent: String?
                                var solVideoUrl: String?
                                var solImageUrl: String?
                                
                                if let surveyId = solution["survey_id"] as? Int {
                                    surId = surveyId
                                }
                                
                                if let solutionContent = solution["content"] as? String {
                                    solContent = solutionContent
                                }
                                
                                if let video: Dictionary<String,Any> = solution["video"] as? Dictionary {
                                    if let url = video["url"] as? String {
                                        solVideoUrl = url
                                    }
                                }
                                
                                if let image: Dictionary<String,Any> = solution["image"] as? Dictionary {
                                    if let url = image["url"] as? String {
                                        solImageUrl = url
                                    }
                                }
                                
                                for survey in self.respondedSurveys {
                                    
                                    if survey.id == surId {
                                        
                                        if let imageUrl = solImageUrl {
                                            survey.solutionImageStringUrl = SERVER_URL + imageUrl
                                        }
                                        if let videoUrl = solVideoUrl {
                                            let videoUrl = URL(string: SERVER_URL + videoUrl)!
                                            survey.solutionVideo = AVPlayer(url: videoUrl as URL)
                                        }
                                    
                                        if let content = solContent {
                                            survey.solutionContent = content
                                        }

                                    }
                                    
                                }
                                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if respondedSurveys.count == 0 {
            return 470
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if respondedSurveys.count == 0 {
            return 470
        } else {
            return 150
        }
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    ////        if respondedSurveys.count != 0 {
    ////            self.delegate.selectedCell(withOption: "GotoSurveyListSegue", data: nil)
    ////        }
    //    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //
    //        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
    //
    //            self.screenedIdeasTableViewHeightConstraint.constant = self.screenedIdeasTableView.contentSize.height
    //        }
    //
    //    }
    
    func formatteDate(stringDate: String?) -> String? {
        if let strDate = stringDate {

            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale // save locale temporarily
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let date = dateFormatter.date(from: strDate)!
            dateFormatter.dateFormat = "dd/MM/yyyy h.mm a"
            dateFormatter.locale = tempLocale // reset the locale
            let dateString = dateFormatter.string(from: date)

            return dateString
        } else {
            return ""
        }

    }
    
    @objc func gotoSegue(_ sender: UIButton) {
        
        if delegate.getUser().isCompleted {
            
            let alert = UIAlertController(title: "You have already become a responder", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
//                self.delegate.selectedCell(withOption: "GotoSurveyListSegue", data: nil)
            })
            alert.addAction(alertAction)
            delegate.getVC().present(alert, animated: true, completion: nil)
            
        } else {
            
            if let tutorialBool = UserDefaults.standard.object(forKey: .keyForResponderTutorial) as? Bool {
                if tutorialBool == true {
                    delegate.selectedCell(withOption: "GotoGetStartedSegue", data: nil)
                }
            } else {
                delegate.selectedCell(withOption: "GotoResponderTutorialSegue", data: nil)
            }
            
        }
        
        
    }
    
    
    
    
}
