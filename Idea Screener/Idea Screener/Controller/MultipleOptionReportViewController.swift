//
//  MultiplyOptionReportViewController.swift
//  Idea Screener
//
//  Created by Silver on 11.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import AVKit

class MultipleOptionReportViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var proposedOptionTableView: UITableView!
    
    @IBOutlet weak var overviewOptionTableView: UITableView!
    
    @IBOutlet weak var proposedOptionTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var overviewOptionTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoCollectionView: UICollectionView!
    
    @IBOutlet weak var problemTextView: UITextView!
    
    @IBOutlet weak var totalRespondersLabel: UILabel!
    
    var survey: Survey!
    
    var errorsArray = [String()]
    
    let optionNameArray = ["Option A","Option B","Option C","Option D"]
    
    let namesData = ["GENDER","AGE","HH INCOME", "EDUCATION LEVEL","LIFESTYLE","RELATIONSHIP STAT","LIFE STAGES","HOME OWNERSHIP"]
    
    let questionsData = ["", "Relevance: How relevant is this problem to you?", "Usefulness: How useful is this solution to you??", "Uniqueness: Is this solution unique and new?", "Shareability: How likely are you to tell your friends about this solution?", "Purchase Intent: How likely are you to buy this product/service?"]
    
    let leftSliderData = ["","Least Relevant", "Not Useful", "Not Unique At All", "Very Unlikely", "Very Unlikely"]
    let rightSliderData = ["", "Extremely Relevant", "Extremely Useful", "Unique, Completely New", "Highly Likely", "Highly Likely"]
    
    var observer: NSObjectProtocol?
    
    var feedbackTableViewHeights = [CGFloat?]()
    
    var flag = true
    
    var maxPercetageID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observer = NotificationCenter.default.addObserver(forName: .feedbackTableHeight, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            let frame = notification.object as! CGRect
            
            self?.feedbackTableViewHeights.append(frame.size.height)
            
            if self?.flag == true {
                
                self?.overviewOptionTableView.reloadData()
                self?.flag = false
                
            }
        })
        
        problemTextView.text = survey.title
        totalRespondersLabel.text = String(survey.maxParticipantsCount)
        
        getSurvey { [unowned self] (result) in
            if result {
                
                DispatchQueue.main.async {
                    self.proposedOptionTableViewHeightConstraint.constant = self.proposedOptionTableView.contentSize.height
                    self.overviewOptionTableViewHeightConstraint.constant = self.overviewOptionTableView.contentSize.height
                }
                
                if let solutions = self.survey.solutions {
                    
                    if solutions.count > 0 {
                        
                        var maxPercentage = 0.0
                        
                        for (index,sol) in solutions.enumerated() {
                            
                            if let perc = sol.percentage {
                                if perc > maxPercentage {
                                    maxPercentage = sol.percentage
                                    self.maxPercetageID = index
                                }
                            }

                            
                            
                        }
                        
                        
                        
                    }
                    
                }
                
                
                self.flag = true
                
                self.proposedOptionTableView.reloadData()
                self.overviewOptionTableView.reloadData()
                
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
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        
    }
    
    
    deinit {
        for i in 0...3 {
            
            if let proposedCell = proposedOptionTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ProposedOptionTableViewCell {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: proposedCell.optionPlayerView.player?.currentItem)
                
            }
            
            if let overviewCell = overviewOptionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? OverviewHeaderTableViewCell {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: overviewCell.optionPlayerView.player?.currentItem)
                
            }
            
        }
        
        print("deinited")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        infoCollectionView.collectionViewLayout.invalidateLayout()
        
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
                                
                                if let id = sol["id"] as? Int {
                                    solution.id = id
                                }
                                
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
                    
                    if let percentage: Array<Dictionary<String,Any>> = object["percentage"] as? Array {
                        
                        if percentage.count > 0 {
                            
                            for percent in percentage {
                                
                                var solutionId = 123
                                
                                if let solId = percent["solution_id"] as? Int {
                                    solutionId = solId
                                }
                                
                                var perc = 0.0
                                
                                if let per = percent["percentage"] as? Double {
                                    perc = per
                                }
                                
                                for solution in self.survey.solutions {
                                    
                                    if solution.id == solutionId {
                                        solution.percentage = perc
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
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case proposedOptionTableView:
            return 1
            
        case overviewOptionTableView:
            if let solutions = survey.solutions {
                return solutions.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case proposedOptionTableView:
            if let solutions = survey.solutions {
                return solutions.count
            } else {
                return 0
            }
        case overviewOptionTableView:
            return 7
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case proposedOptionTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProposedOptionCell", for: indexPath) as! ProposedOptionTableViewCell
            
            cell.optionName.text = optionNameArray[indexPath.row]
            
            if let solutions = survey.solutions {
                
                let solution = solutions[indexPath.row]
                
                if let content = solution.content {
                    cell.optionContentView.isHidden = false
                    cell.optionTextView.text = content
                }
                
                if indexPath.row == maxPercetageID {
                    cell.bgView.backgroundColor = #colorLiteral(red: 0.9495088458, green: 0.9695112109, blue: 1, alpha: 1)
                } else {
                    cell.bgView.backgroundColor = .white
                }
                
                if let percentage = solution.percentage {
                    cell.percentLabel.text = String(format: "%.1f", percentage) + "%"
                    DispatchQueue.main.async {
                        cell.progressFrontView.frame.size.width = CGFloat(percentage) * cell.progressBackView.frame.size.width / 100
                    }
                }
                
                if let imageStringUrl = solution.imageStringUrl {
                    
                    print(imageStringUrl)
                    if imageStringUrl != "<null>" {
                        if let url = URL(string: SERVER_URL + imageStringUrl) {
                            cell.optionImageView.downloadedFrom(url: url)
                            cell.optionImageView.isHidden = false
                        }
                    }
                    
                }
                
                if let video = solution.videoStringUrl {
                    
                    print(video)
                    if video != "<null>" {
                        if let url = URL(string: SERVER_URL + video) {
                            cell.optionPlayerView.playerLayer.player = AVPlayer(url: url as URL)
                            cell.optionPlayerView.isHidden = false
                            if cell.optionPlayerView.isHidden == false {
                                cell.playBtn.tag = indexPath.row
                                cell.playBtn.addTarget(self, action: #selector(playProposedVideoBtnTap(_:)), for: .touchUpInside)
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
        case overviewOptionTableView:
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderOverviewCell", for: indexPath) as! OverviewHeaderTableViewCell
                
                cell.optionNameLabel.text = optionNameArray[indexPath.section]
                
                if let solutions = survey.solutions {
                    
                    let solution = solutions[indexPath.section]
                    
                    if let content = solution.content {
                        cell.optionContentView.isHidden = false
                        cell.optionTextView.text = content
                    }
                    
                    if let percentage = solution.percentage {
                        cell.percentLabel.text = String(format: "%.1f", percentage) + "%"
                        DispatchQueue.main.async {
                            cell.progressFrontView.frame.size.width = CGFloat(percentage) * cell.progressBackView.frame.size.width / 100
                        }
                    }
                    
                    if let imageStringUrl = solution.imageStringUrl {
                        
                        print(imageStringUrl)
                        if imageStringUrl != "<null>" {
                            if let url = URL(string: SERVER_URL + imageStringUrl) {
                                cell.optionImageView.downloadedFrom(url: url)
                                cell.optionImageView.isHidden = false
                            }
                        }
                        
                    }
                    
                    if let video = solution.videoStringUrl {
                        
                        print(video)
                        if video != "<null>" {
                            if let url = URL(string: SERVER_URL + video) {
                                cell.optionPlayerView.playerLayer.player = AVPlayer(url: url as URL)
                                cell.optionPlayerView.isHidden = false
                                if cell.optionPlayerView.isHidden == false {
                                    cell.playBtn.tag = indexPath.section
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
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackTableCell", for: indexPath) as! FeedbackTableViewCell
                
                if let solutions = survey.solutions {
                    
                    let solution = solutions[indexPath.section]
                    if let feedbacks = solution.feedbacks {
                        cell.feedbacks = feedbacks
                    }
                    
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionResultCell", for: indexPath) as! QuestionResultTableViewCell
                
                if let solutions = survey.solutions {
                    
                    let solution = solutions[indexPath.section]
                    
                    cell.rateLabel.text = String(format: "%.1f", solution.rates[indexPath.row - 1])
                    
                    DispatchQueue.main.async {
                        
                        cell.progressFrontView.frame.size.width = CGFloat(solution.rates[indexPath.row - 1] - 1.0) * cell.progressBackView.frame.size.width / 4
                        
                        cell.rateLabel.transform = CGAffineTransform(translationX: cell.progressFrontView.frame.size.width, y: 0)
                    }
                }
                
                
                cell.questionLabel.text = questionsData[indexPath.row]
                cell.leftSliderLabel.text = leftSliderData[indexPath.row]
                cell.rightSliderLabel.text = rightSliderData[indexPath.row]
                
                return cell
            }
            
            
        default:
            return UITableViewCell()
        }
        
    }
    
    @objc func playVideoBtnTap(_ sender: UIButton) {
        if let optionCell = overviewOptionTableView.cellForRow(at: IndexPath(row: 0, section: sender.tag)) as? OverviewHeaderTableViewCell {
            
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
    
    @objc func playProposedVideoBtnTap(_ sender: UIButton) {
        if let optionCell = proposedOptionTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? ProposedOptionTableViewCell {
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case proposedOptionTableView:
            return UITableViewAutomaticDimension
        case overviewOptionTableView:
            switch indexPath.row {
            case 6:
                
                if feedbackTableViewHeights.count > 0 {
                    if let feedbackTableViewHeight = feedbackTableViewHeights[indexPath.section] {
                        return feedbackTableViewHeight + 95 // rowheight * data.count + 95 // return Feedback tableview height + top + bottom space + label height + space between table and label
                    }
                }

                return UITableViewAutomaticDimension
            default:
                return UITableViewAutomaticDimension
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch tableView {
        case proposedOptionTableView:
            if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
                proposedOptionTableViewHeightConstraint.constant = proposedOptionTableView.contentSize.height
            }
        case overviewOptionTableView:
            if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
                overviewOptionTableViewHeightConstraint.constant = overviewOptionTableView.contentSize.height
                
            }
        default:
            return
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
