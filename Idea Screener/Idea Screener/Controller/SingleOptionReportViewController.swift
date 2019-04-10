//
//  SingleOptionReportViewController.swift
//  Idea Screener
//
//  Created by Silver on 10.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import AVKit

class SingleOptionReportViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedbackTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var feedbackTableView: UITableView!
    
    @IBOutlet weak var solutionTableView: UITableView!
    
    @IBOutlet weak var solutionTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var problemTextView: UITextView!
    
    @IBOutlet weak var solutionTextView: UITextView!
    
    @IBOutlet weak var infoCollectionView: UICollectionView!
    
    @IBOutlet weak var totalRespondersLabel: UILabel!
    
    @IBOutlet weak var relevanceRateLabel: UILabel!
    
    @IBOutlet weak var relevanceProgressBackView: DesignableView!
    
    @IBOutlet weak var relevanceProgressFrontView: DesignableView!
    
    @IBOutlet weak var usefulnessRateLabel: UILabel!
    
    @IBOutlet weak var usefulnessProgressBackView: DesignableView!
    
    @IBOutlet weak var usefulnessProgressFrontView: DesignableView!
    
    @IBOutlet weak var uniquenessRateLabel: UILabel!
    
    @IBOutlet weak var uniquenessProgressBackView: DesignableView!
    
    @IBOutlet weak var uniquenessProgressFrontView: DesignableView!
    
    @IBOutlet weak var shareabilityRateLabel: UILabel!
    
    @IBOutlet weak var shareabilityProgressBackView: DesignableView!
    
    @IBOutlet weak var shareabilityProgressFrontView: DesignableView!
    
    @IBOutlet weak var purchaseIntentRateLabel: UILabel!
    
    @IBOutlet weak var purchaseIntentProgressBackView: DesignableView!
    
    @IBOutlet weak var purchaseIntentProgressFrontView: DesignableView!
    
    var survey: Survey!
    
    var errorsArray = [String()]
    
    let namesData = ["GENDER","AGE","HH INCOME","EDUCATION LEVEL","LIFESTYLE","RELATIONSHIP STAT","LIFE STAGES","HOME OWNERSHIP"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        problemTextView.text = survey.title
        totalRespondersLabel.text = String(survey.maxParticipantsCount)
        
        getSurvey {  [unowned self] (result) in
            if result {
                DispatchQueue.main.async {
                    self.solutionTableViewHeightConstraint.constant = self.solutionTableView.contentSize.height
                    self.feedbackTableViewHeightConstraint.constant = self.feedbackTableView.contentSize.height
                }
                
                if let solutions = self.survey.solutions {
                    if let rates = solutions[0].rates {
                        self.relevanceRateLabel.text = String(format: "%.1f", rates[0])
                        self.usefulnessRateLabel.text = String(format: "%.1f", rates[1])
                        self.uniquenessRateLabel.text = String(format: "%.1f", rates[2])
                        self.shareabilityRateLabel.text = String(format: "%.1f", rates[3])
                        self.purchaseIntentRateLabel.text = String(format: "%.1f", rates[4])
                        
                        DispatchQueue.main.async {
                            self.relevanceProgressFrontView.frame.size.width = CGFloat(self.survey.solutions[0].rates[0] - 1.0) * self.relevanceProgressBackView.frame.size.width / 4
                            self.usefulnessProgressFrontView.frame.size.width = CGFloat(self.survey.solutions[0].rates[1] - 1.0) * self.usefulnessProgressBackView.frame.size.width / 4
                            self.uniquenessProgressFrontView.frame.size.width = CGFloat(self.survey.solutions[0].rates[2] - 1.0) * self.uniquenessProgressBackView.frame.size.width / 4
                            self.shareabilityProgressFrontView.frame.size.width = CGFloat(self.survey.solutions[0].rates[3] - 1.0) * self.shareabilityProgressBackView.frame.size.width / 4
                            self.purchaseIntentProgressFrontView.frame.size.width = CGFloat(self.survey.solutions[0].rates[4] - 1.0) * self.purchaseIntentProgressBackView.frame.size.width / 4
                            
                            self.relevanceRateLabel.transform = CGAffineTransform(translationX: self.relevanceProgressFrontView.frame.size.width, y: 0)
                            self.usefulnessRateLabel.transform = CGAffineTransform(translationX: self.usefulnessProgressFrontView.frame.size.width, y: 0)
                            self.uniquenessRateLabel.transform = CGAffineTransform(translationX: self.uniquenessProgressFrontView.frame.size.width, y: 0)
                            self.shareabilityRateLabel.transform = CGAffineTransform(translationX: self.shareabilityProgressFrontView.frame.size.width, y: 0)
                            self.purchaseIntentRateLabel.transform = CGAffineTransform(translationX: self.purchaseIntentProgressFrontView.frame.size.width, y: 0)
                        }

                    }
                }


                self.solutionTableView.reloadData()
                self.feedbackTableView.reloadData()
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
    
    deinit {
        print("deinited")
        
        if let solutionCell = solutionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SingleReportSolutionTableViewCell {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: solutionCell.optionPlayerView.player?.currentItem)
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        infoCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getSurvey(complete: @escaping DownloadComplete) {
        
        let stringUrl = SURVEYS_URL + "/" + survey.id
        
        let url = URL(string: stringUrl)!
        
        request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":"Bearer " + USER_TOKEN]).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                
                if let object:Dictionary<String,Any> = data as? Dictionary {
                    
                    if let message = object["error"] as? String {
                        self.errorsArray.append(message)
                        
                        complete(false)
                        return
                        
                    }
                    
                    
                    if let sols: Array<Dictionary<String,Any>> = object["solutions"] as? Array {
                        
                        var solutions = [Solution]()

                        if sols.count > 0 {
                            
                            for sol in sols {
                                
                                        let solution = Solution()
                                        
                                        if let content = sol["content"] as? String {
                                            solution.content = content
                                        }
                                        
                                        if let image: Dictionary<String,Any> = sol["image"] as? Dictionary {
                                            if let url = image["url"] as? String {
                                                solution.imageStringUrl = url
                                            }
                                        }
                                        
                                        if let video: Dictionary<String,Any> = sol["video"] as? Dictionary {
                                            if let url = video["url"] as? String {
                                                solution.videoStringUrl = url
                                            }
                                        }
                                        
                                        var solutionRatesArray = [1.0,1.0,1.0,1.0,1.0]
                                        
                                        if let solutionRates: Dictionary<String,Any> = sol["solution_rates"] as? Dictionary {
                                            
                                            if let relevance = solutionRates["relevance"] as? String {
                                                solutionRatesArray[0] = Double(relevance)!
                                            }
                                            
                                            if let usefulness = solutionRates["usefulness"] as? String {
                                                solutionRatesArray[1] = Double(usefulness)!
                                            }
                                            
                                            if let uniqueness = solutionRates["uniqueness"] as? String {
                                                solutionRatesArray[2] = Double(uniqueness)!
                                            }
                                            
                                            if let shareability = solutionRates["shareability"] as? String {
                                                solutionRatesArray[3] = Double(shareability)!
                                            }
                                            
                                            if let purchaseIntent = solutionRates["purchase_intent"] as? String {
                                                solutionRatesArray[4] = Double(purchaseIntent)!
                                            }
                                            
                                        }
                                        
                                        solution.rates = solutionRatesArray
                                        
                                        if let feedbacks:Array<Dictionary<String,Any>> = sol["feedbacks"] as? Array {
                                            
                                            var feedbacksArray = [String]()

                                            if feedbacks.count > 0 {
                                                
                                                for feedback in feedbacks {
                                                    
                                                    if let content = feedback["content"] as? String {
                                                        feedbacksArray.append(content)
                                                    }
                                                }
                                                
                                            }
                                            
                                            solution.feedbacks = feedbacksArray
                                            
                                        }
                                        
                                        solutions.append(solution)
                                
                            }
                            
                        }
                        
                        self.survey.solutions = solutions
                        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return survey.targetAudience.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TargetAudienceCell", for: indexPath) as! TargetAudienceReportCollectionViewCell
        
        cell.targetNameLabel.text = namesData[indexPath.row]
        cell.targetInfoLabel.text = survey.targetAudience[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3, height: collectionView.frame.size.height / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case feedbackTableView:
            if let solutions = survey.solutions {
                return solutions[0].feedbacks.count
            } else {
                return 0
            }
        case solutionTableView:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case feedbackTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackOptionTableViewCell
            if let solutions = survey.solutions {
                let feedback = solutions[0].feedbacks[indexPath.row]
                cell.msgTextLabel.text = feedback
            }
            
            return cell
        case solutionTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleReportSolutionCell", for: indexPath) as! SingleReportSolutionTableViewCell
            
            if let solutions = survey.solutions {
                if let content = solutions[0].content {
                    cell.optionTextView.text = content
                }
                
                if let imageStringUrl = solutions[0].imageStringUrl {
                    
                    print(imageStringUrl)
                    if imageStringUrl != "<null>" {
                        if let url = URL(string: SERVER_URL + imageStringUrl) {
                            cell.optionImageView.downloadedFrom(url: url)
                            cell.optionImageView.isHidden = false
                        }
                    }
                    
                }
                
                if let video = solutions[0].videoStringUrl {
                    
                    print(video)
                    if video != "<null>" {
                        if let url = URL(string: SERVER_URL + video) {
                            cell.optionPlayerView.playerLayer.player = AVPlayer(url: url as URL)
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
                    }
                    
                }
                
            }

            
            return cell
        default:
            return UITableViewCell()
        }

    }
    
    @objc func playVideoBtnTap(_ sender: UIButton) {
        if let optionCell = solutionTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? SingleReportSolutionTableViewCell {
            
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch tableView {
        case solutionTableView:
            if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
                
                self.solutionTableViewHeightConstraint.constant = self.solutionTableView.contentSize.height
            }
        default:
            break
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
