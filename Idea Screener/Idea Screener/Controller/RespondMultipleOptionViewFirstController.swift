//
//  RespondMultipleOptionViewController.swift
//  Idea Screener
//
//  Created by Silver on 13.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class RespondMultipleOptionFirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var optionsTableView: UITableView!
    
    @IBOutlet weak var optionsTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var problemLabel: UILabel!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var tagId = Int()
    
    let optionNameArray = ["Option A","Option B","Option C","Option D"]
    
    var savedRespondSolution: RespondSolution?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        problemLabel.text = respondSurvey.problem
        
        notificationStart = false

        DispatchQueue.main.async {
            self.optionsTableViewHeightConstraint.constant = self.optionsTableView.contentSize.height
            self.optionsTableView.reloadData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let alert = UIAlertController(title: "Yeaman", message: respondSurvey.solutions![0].content!, preferredStyle: .alert)
//        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(alertAction)
//        self.present(alert, animated: true, completion: {
//        })
        
    }
    
    deinit {
        print("deinited")
        
        for i in 0...3 {
            
            if let optionCell = optionsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? RespondOptionTableViewCell {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: optionCell.optionPlayerView.player?.currentItem)
                
            }
            
        }
        
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (respondSurvey.solutions?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: "MultipleChoiceCell", for: indexPath) as! RespondOptionTableViewCell
        
        cell.optionNameLabel.text = optionNameArray[indexPath.row]
        if let content = respondSurvey.solutions![indexPath.row].content {
            cell.optionTextView.text = content
        }
        
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
                cell.optionPlayBtn.tag = indexPath.row
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
        tagId = sender.tag
        if let optionCell = optionsTableView.cellForRow(at: IndexPath(row: tagId, section: 0)) as? RespondOptionTableViewCell {
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RespondOptionTableViewCell
        
        cell.optionCheckImageView.image = #imageLiteral(resourceName: "ic_checkmark")
        
        respondSurvey.solutions![indexPath.row].optionName = optionNameArray[indexPath.row]
        savedRespondSolution = respondSurvey.solutions![indexPath.row]
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RespondOptionTableViewCell
        
        cell.optionCheckImageView.image = #imageLiteral(resourceName: "ic_uncheckedmark")
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            
            self.optionsTableViewHeightConstraint.constant = self.optionsTableView.contentSize.height
        }
        
    }
    
    @IBAction func nextBtnTap(_ sender: UIButton) {

        if savedRespondSolution != nil {
            
            self.performSegue(withIdentifier: "GotoSecondControllerSegue", sender: savedRespondSolution)
            
        } else {
            let alert = UIAlertController(title: nil, message: "You have to pick one of the solutions", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoSecondControllerSegue" {
            if let respondMultipleOptionSecondViewController = segue.destination as? RespondMultipleOptionSecondViewController {
                if let savedSolution = sender as? RespondSolution {
                    respondMultipleOptionSecondViewController.respondSolution = savedSolution
                }
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
