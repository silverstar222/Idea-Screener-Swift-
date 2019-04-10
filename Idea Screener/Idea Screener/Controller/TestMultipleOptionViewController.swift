//
//  TestMultiplyOptionViewController.swift
//  Idea Screener
//
//  Created by Silver on 10.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TestMultipleOptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet var toolBarView: UIView!
    
    @IBOutlet weak var problemTextView: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
        
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var solutionTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    let alert = AttachmentHandler.shared
    
    let optionData = OptionData()
    
    let placeholderTextData = ["Option A - Input your solution option here.\nEnter text, image, or video","Option B - Input your solution option here.\nEnter text, image, or video","Option C - Input your solution option here.\nEnter text, image, or video","Option D - Input your solution option here.\nEnter text, image, or video"]
    
    var isEditingFirstTime = true
    
    var savedText = ""
    
    var solutionArray = [Solution()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        registerForKeyboardNotifications()
        
        setupView()
        
    }
    
    func setupView() {
        
        toolBarView.frame.size.height = 40
        toolBarView.frame.size.width = self.view.frame.size.width
        
    }
    
    
    deinit {
        for i in 0...3 {
            
            if let solutionCell = solutionTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? OptionTableViewCell {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: solutionCell.playerView.player?.currentItem)
                
            }
            
        }
        
        
        removeKeyboardNotifications()
        
        print("deinited")
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
        
        //                scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
        
        viewBottomConstraint.constant = kbFrameSize.height
        
    }
    
    @objc func kbWillHide() {
        //        scrollView.contentOffset = CGPoint.zero
        
        viewBottomConstraint.constant = 0
        
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isEditingFirstTime || problemTextView.text == savedText {
            savedText = problemTextView.text
            problemTextView.text = ""
            isEditingFirstTime = false
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if problemTextView.text.isEmpty {
            problemTextView.text = savedText
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solutionArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == solutionArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewOptionCell", for: indexPath)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionTableViewCell
            
            cell.optionTextView.tag = indexPath.row
            
            cell.optionTextView.inputAccessoryView = toolBarView
            
            if cell.playerView.isHidden == false {
                cell.playBtn.addTarget(self, action: #selector(playVideoBtnTap(_:)), for: .touchUpInside)
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: cell.playerView.player?.currentItem, queue: .main) { _ in
                    cell.playerView.player?.seek(to: kCMTimeZero)
                    cell.playerView.player?.pause()
                    cell.videoIsPlaying = false
                    cell.playBtn.setImage(#imageLiteral(resourceName: "img_play_btn"), for: .normal)
                    
                }
                
            }
            
            return cell
        }
        
        
    }
    
    @objc func playVideoBtnTap(_ sender: UIButton) {
        if let solutionCell = solutionTableView.cellForRow(at: IndexPath(row: globalOptionTagId, section: 0)) as? OptionTableViewCell {
            
            if solutionCell.videoIsPlaying == false {
                solutionCell.playerView.player?.play()
                solutionCell.videoIsPlaying = true
                solutionCell.playBtn.setImage(UIImage(), for: .normal)
            } else {
                solutionCell.playerView.player?.pause()
                solutionCell.videoIsPlaying = false
                solutionCell.playBtn.setImage(#imageLiteral(resourceName: "img_play_btn"), for: .normal)
            }
            
            
            
        }
    }
    
    
    @IBAction func attachImageOrVideoBtnTap(_ sender: UIButton) {
        
        if let solutionCell = solutionTableView.cellForRow(at: IndexPath(row: globalOptionTagId, section: 0)) as? OptionTableViewCell {
            
            DispatchQueue.main.async { [unowned self] in
                self.alert.showAttachmentActionSheet(vc: self)
                self.alert.imagePickedBlock = { (image) in
                    
                    let imgData = UIImageJPEGRepresentation(image, 0.5)!
                    
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
                    
                    solutionCell.optionImageView.image = image
                    solutionCell.optionImageView.isHidden = false
                    
                    self.solutionArray[globalOptionTagId].imageData = imgData
                    
                    self.solutionTableView.reloadData()
                    
                    
                }
                
                self.alert.videoPickedBlock = { (video) in
                    
                    do {
                        let data = try Data(contentsOf: video as URL, options: .mappedIfSafe)
                        
                        let dataSize = Double(data.count) / (1024*1024)
                        print("DataSize = \(dataSize) MB")
                        
                        if dataSize > 50 {
                            
                            let alert = UIAlertController(title: "Error", message: "Video size is too big (50 MB max)!", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(alertAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                            return
                            
                        }
                        
                        self.solutionArray[globalOptionTagId].videoData = data
                        
                    } catch {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(alertAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    let avPlayer = AVPlayer(url: video as URL)
                    solutionCell.playerView.playerLayer.player = avPlayer
                    solutionCell.playerView.isHidden = false
                    
                    self.solutionTableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if solutionArray.count != 4 {
            if indexPath.row == solutionArray.count {
                solutionArray.append(Solution())
                tableView.insertRows(at: [IndexPath.init(row: solutionArray.count - 1, section: 0)], with: .automatic)
                let cell = tableView.cellForRow(at: IndexPath(row: solutionArray.count - 1, section: 0)) as! OptionTableViewCell
                cell.optionTextView.text = placeholderTextData[indexPath.row]
                tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < solutionArray.count {
            return true
        } else {
            return false
        }
        
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row < solutionArray.count {
            let delete = UIContextualAction(style: .destructive, title: "Delete Option") { (action, view, nil) in
                let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
                
                cell.optionImageView.isHidden = true
                cell.playerView.isHidden = true
                cell.optionImageView.image = UIImage()
                cell.playerView.playerLayer.player = nil
                
                self.solutionArray.remove(at: indexPath.row)
                tableView.reloadData()
            }
            
            
            return UISwipeActionsConfiguration(actions: [delete])
            
        } else {
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            
            self.tableViewHeightConstraint.constant = self.solutionTableView.contentSize.height
        }
        
    }
    
    @IBAction func nextBtnTap(_ sender: UIButton) {
        
        if problemTextView.text.contains("Write your answer here") || problemTextView.text.isEmpty {
            let alert = UIAlertController(title: nil, message: "Problem field is empty!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        optionData.problem = problemTextView.text
        
        if let firstSolutionCell = solutionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OptionTableViewCell {
            if firstSolutionCell.optionTextView.text.contains("- Input your solution option here.") || firstSolutionCell.optionTextView.text.isEmpty {
                let alert = UIAlertController(title: nil, message: "First solution text field is empty!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            solutionArray[0].content = firstSolutionCell.optionTextView.text
        }
        
        if let secondSolutionCell = solutionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? OptionTableViewCell {
            if secondSolutionCell.optionTextView.text.contains("- Input your solution option here.") || secondSolutionCell.optionTextView.text.isEmpty {
                let alert = UIAlertController(title: nil, message: "Second solution text field is empty!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            solutionArray[1].content = secondSolutionCell.optionTextView.text
        }
        
        if let thirdSolutionCell = solutionTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? OptionTableViewCell {
            if thirdSolutionCell.optionTextView.text.contains("- Input your solution option here.") || thirdSolutionCell.optionTextView.text.isEmpty {
                let alert = UIAlertController(title: nil, message: "Third solution text field is empty!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            solutionArray[2].content = thirdSolutionCell.optionTextView.text
        }
        
        if let fourthSolutionCell = solutionTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? OptionTableViewCell {
            if fourthSolutionCell.optionTextView.text.contains("- Input your solution option here.") || fourthSolutionCell.optionTextView.text.isEmpty {
                let alert = UIAlertController(title: nil, message: "Fourth solution text field is empty!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            solutionArray[3].content = fourthSolutionCell.optionTextView.text
        }
        
        optionData.solutions = solutionArray
        
        optionData.type = "test_multiple_question"
        
        performSegue(withIdentifier: "GotoTargetAudienceSegue", sender: optionData)
        
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoTargetAudienceSegue" {
            if let targetAudienceViewController = segue.destination as? TargetAudienceViewController {
                if let dataToPass = sender as? OptionData {
                    targetAudienceViewController.optionData = dataToPass
                }
            }
        }
    }
    
}
