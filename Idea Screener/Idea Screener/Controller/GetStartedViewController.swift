//
//  GetStartedViewController.swift
//  Idea Screener
//
//  Created by Silver on 10.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var genderTableView: UITableView!
    
    @IBOutlet weak var ageTableView: UITableView!
    
    @IBOutlet weak var incomeTableView: UITableView!
    
    @IBOutlet weak var educationTableView: UITableView!
    
    @IBOutlet weak var lifestyleTableView: UITableView!
    
    @IBOutlet weak var relationshipTableView: UITableView!
    
    @IBOutlet weak var lifeStageTableView: UITableView!
    
    @IBOutlet weak var ownershipTableView: UITableView!
    
    @IBOutlet weak var genderTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ageTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var incomeTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var educationTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lifestyleTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var relationshipTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lifeStageTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ownershipTableViewHeightConstraint: NSLayoutConstraint!
    
    let genderData = ["Male","Female"]
    let ageData = ["18-24","25-30","31-40","41-60","61 and older"]
    let incomeData = ["Below $30k","Between $30k and $45k","Between $44k and $75k","Between $76k and $100k","Above $100k"]
    let educationData = ["Did not complete High School","High School","College","Advanced Degree"]
    let lifestyleData = ["Urban","Rural","Suburban"]
    let relationshipData = ["Single","Married"]
    let lifeStageData = ["Has kids in the home","No Kids in the home"]
    let ownershipData = ["Own a home","Don’t own a home"]
    
    var dataToPass = ["","","","","","","",""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewHeights()
        
    }
    
    func setTableViewHeights() {
        
        genderTableViewHeightConstraint.constant = genderTableView.rowHeight * CGFloat(genderData.count)
        
        ageTableViewHeightConstraint.constant = ageTableView.rowHeight * CGFloat(ageData.count)
        
        incomeTableViewHeightConstraint.constant = incomeTableView.rowHeight * CGFloat(incomeData.count)
        
        educationTableViewHeightConstraint.constant = educationTableView.rowHeight * CGFloat(educationData.count)
        
        lifestyleTableViewHeightConstraint.constant = lifestyleTableView.rowHeight * CGFloat(lifestyleData.count)
        
        relationshipTableViewHeightConstraint.constant = relationshipTableView.rowHeight * CGFloat(relationshipData.count)
        
        lifeStageTableViewHeightConstraint.constant = lifeStageTableView.rowHeight * CGFloat(lifeStageData.count)
        
        ownershipTableViewHeightConstraint.constant = ownershipTableView.rowHeight * CGFloat(ownershipData.count)
        
        
    }
    @IBAction func nextBtnTap(_ sender: UIButton) {
        
        for data in dataToPass {
            if data.isEmpty {
                
                let alert = UIAlertController(title: nil, message: "Empty field found", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(alertAction)
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
        }
        
        performSegue(withIdentifier: "GotoConfirmationSegue", sender: dataToPass)
    }
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case genderTableView:
            return genderData.count
        case ageTableView:
            return ageData.count
        case incomeTableView:
            return incomeData.count
        case educationTableView:
            return educationData.count
        case lifestyleTableView:
            return lifestyleData.count
        case relationshipTableView:
            return relationshipData.count
        case lifeStageTableView:
            return lifeStageData.count
        case ownershipTableView:
            return ownershipData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case genderTableView:
            let cell = genderTableView.dequeueReusableCell(withIdentifier: "AudienceGenderCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = genderData[indexPath.row]
            return cell
        case ageTableView:
            let cell = ageTableView.dequeueReusableCell(withIdentifier: "AudienceAgeCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = ageData[indexPath.row]
            return cell
        case incomeTableView:
            let cell = incomeTableView.dequeueReusableCell(withIdentifier: "AudienceIncomeCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = incomeData[indexPath.row]
            return cell
        case educationTableView:
            let cell = educationTableView.dequeueReusableCell(withIdentifier: "AudienceEducationCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = educationData[indexPath.row]
            return cell
        case lifestyleTableView:
            let cell = lifestyleTableView.dequeueReusableCell(withIdentifier: "AudienceLifestyleCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = lifestyleData[indexPath.row]
            return cell
        case relationshipTableView:
            let cell = relationshipTableView.dequeueReusableCell(withIdentifier: "AudienceRelationshipCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = relationshipData[indexPath.row]
            return cell
        case lifeStageTableView:
            let cell = lifeStageTableView.dequeueReusableCell(withIdentifier: "AudienceLifeStageCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = lifeStageData[indexPath.row]
            return cell
        case ownershipTableView:
            let cell = ownershipTableView.dequeueReusableCell(withIdentifier: "AudienceOwnershipCell", for: indexPath) as! AudienceTableViewCell
            
            cell.questionLabel.text = ownershipData[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AudienceTableViewCell
        
        cell.checkmarkImageView.image = #imageLiteral(resourceName: "ic_checkmark")
        cell.bgView.layer.borderWidth = 1
        
        switch tableView {
        case genderTableView:
            dataToPass[0] = cell.questionLabel.text!
        case ageTableView:
            dataToPass[1] = cell.questionLabel.text!
        case incomeTableView:
            dataToPass[2] = cell.questionLabel.text!
        case educationTableView:
            dataToPass[3] = cell.questionLabel.text!
        case lifestyleTableView:
            dataToPass[4] = cell.questionLabel.text!
        case relationshipTableView:
            dataToPass[5] = cell.questionLabel.text!
        case lifeStageTableView:
            dataToPass[6] = cell.questionLabel.text!
        case ownershipTableView:
            dataToPass[7] = cell.questionLabel.text!
        default:
            print("hz")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AudienceTableViewCell
        
        cell.checkmarkImageView.image = #imageLiteral(resourceName: "ic_uncheckedmark")
        cell.bgView.layer.borderWidth = 0
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoConfirmationSegue" {
            if let responderConfirmationViewController = segue.destination as? ResponderConfirmationViewController {
                if let dataToPass = sender as? [String] {
                    responderConfirmationViewController.passedData = dataToPass
                }
            }
        }
    }
    
    
    
    
}
