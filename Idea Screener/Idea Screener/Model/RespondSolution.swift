//
//  RespondSolution.swift
//  Idea Screener
//
//  Created by Silver on 03.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class RespondSolution: NSObject {
    
    var content: String!
    var video: AVPlayer!
    var imageStringUrl: String!
    var id: Int!
    var surveyId: Int!
    var userId: Int!
    
    var image: UIImage!
    
    var optionName: String!
    
    var feedback: String!
    
    var relevanceValue: Double!
    var uniquenessValue: Double!
    var usefulnessValue: Double!
    var shareabilityValue: Double!
    var purchaseIntentValue: Double!

}
