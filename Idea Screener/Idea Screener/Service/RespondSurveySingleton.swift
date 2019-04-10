//
//  SurveySingleton.swift
//  Idea Screener
//
//  Created by Silver on 02.05.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import Foundation

class RespondSurvey {
    
    // MARK: - Properties
    
   private static var survey: RespondSurvey?

    var problem: String?
    var questionId: Int?
    var type: String?
    var solutions: [RespondSolution]?
    var costPerUser: Double?
    var userId: Int?
    var id: Int?
    
    class func shared() -> RespondSurvey {
        
        if self.survey == nil {
            self.survey = RespondSurvey()
        }
        
        return self.survey!
    }
    
}
