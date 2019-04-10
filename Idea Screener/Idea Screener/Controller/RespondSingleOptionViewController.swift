//
//  RespondSingleOptionViewController.swift
//  Idea Screener
//
//  Created by Silver on 12.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire

class RespondSingleOptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var solutionTableView: UITableView!
    
    @IBOutlet weak var solutionTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var problemLabel: UILabel!
    
    @IBOutlet weak var relevanceSlider: UISlider!
    
    @IBOutlet weak var usefulnessSlider: UISlider!
    
    @IBOutlet weak var uniquenessSlider: UISlider!
    
    @IBOutlet weak var shareabilitySlider: UISlider!
    
    @IBOutlet weak var purchaseIntentSlider: UISlider!
    
    @IBOutlet weak var feedbackTextView: UITextView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    var respondSolution = RespondSolution()

    var errorsArray = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationStart = false
        
        problemLabel.text = respondSurvey.problem
        
        self.hideKeyboardWhenTappedAround()
        
        registerForKeyboardNotifications()
        
        DispatchQueue.main.async {
            self.solutionTableViewHeightConstraint.constant = self.solutionTableView.contentSize.height
            self.solutionTableView.reloadData()
        }
    }
    
    deinit {
        print("deinited")
        
        if let optionCell = solutionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RespondOptionTableViewCell {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: optionCell.optionPlayerView.player?.currentItem)
            
        }
        
        removeKeyboardNotifications()
    }

    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func confirmBtnTap(_ sender: UIButton) {
        
        let feedbackText = feedbackTextView.text!
        
        if feedbackText == "Write your feedback" || feedbackText.isEmpty {
            let alert = UIAlertController(title: "Error", message: "You have to write your feedback!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil )
            return
        }

        respondSolution.surveyId = respondSurvey.id!
        respondSolution.id = respondSurvey.solutions![0].id!
        respondSolution.userId = respondSurvey.userId!
        respondSolution.feedback = feedbackText
        respondSolution.relevanceValue = Double(relevanceSlider.value)
        respondSolution.uniquenessValue = Double(uniquenessSlider.value)
        respondSolution.usefulnessValue = Double(usefulnessSlider.value)
        respondSolution.shareabilityValue = Double(shareabilitySlider.value)
        respondSolution.purchaseIntentValue = Double(purchaseIntentSlider.value)
        
        self.performSegue(withIdentifier: "GotoRespondBillingSegue", sender: respondSolution)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (respondSurvey.solutions?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SolutionCell", for: indexPath) as! RespondOptionTableViewCell
        
        cell.optionTextView.text = respondSurvey.solutions![indexPath.row].content!
        
        if let imageStringUrl = respondSurvey.solutions![indexPath.row].imageStringUrl {
            
            if let url = URL(string: imageStringUrl) {
                cell.optionImageView.downloadedFrom(url: url)
                cell.optionImageView.isHidden = false
            }
            
        }
        
        if let video = respondSurvey.solutions![indexPath.row].video {
            
            cell.optionPlayerView.playerLayer.player = video
            cell.optionPlayerView.isHidden = false
            if cell.optionPlayerView.isHidden == false {
                cell.optionPlayBtn.addTarget(self, action: #selector(playVideoBtnTap(_:)), for: .touchUpInside)
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: cell.optionPlayerView.player?.currentItem, queue: .main) { _ in
                    cell.optionPlayerView.player?.seek(to: kCMTimeZero)
                    cell.optionPlayerView.player?.pause()
                    cell.videoIsPlaying = false
                    cell.optionPlayBtn.setImage(#imageLiteral(resourceName: "img_play_btn"), for: .normal)
                    
                }
                
            }
            
            
        }
        
        return cell
    }
    
    @objc func playVideoBtnTap(_ sender: UIButton) {
        if let optionCell = solutionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RespondOptionTableViewCell {
            
            if optionCell.videoIsPlaying == false {
                optionCell.optionPlayerView.player?.play()
                optionCell.videoIsPlaying = true
                optionCell.optionPlayBtn.setImage(UIImage(), for: .normal)
            } else {
                optionCell.optionPlayerView.player?.pause()
                optionCell.videoIsPlaying = false
                optionCell.optionPlayBtn.setImage(#imageLiteral(resourceName: "img_play_btn"), for: .normal)
            }
            
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            
            self.solutionTableViewHeightConstraint.constant = self.solutionTableView.contentSize.height
        }
        
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
        
        
        bottomViewConstraint.constant = kbFrameSize.height - 65 - 34
        
        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height * 6)

        
    }
    
    @objc func kbWillHide() {
        
        scrollView.contentOffset = CGPoint.zero
        
        bottomViewConstraint.constant = 0
        

    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoRespondBillingSegue" {
            if let respondBillingInformationViewController = segue.destination as? RespondBillingInformationViewController {
                if let respondSolution = sender as? RespondSolution {
                    respondBillingInformationViewController.respondSolution = respondSolution
                }
            }
        }
    }

}
