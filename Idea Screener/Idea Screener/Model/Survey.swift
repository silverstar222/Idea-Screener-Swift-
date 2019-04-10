//
//  Survey.swift
//  Idea Screener
//
//  Created by Silver on 26.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import Foundation


class Survey: NSObject {
    
    var title: String!
    var id: String!
    var status: String!
    var type: String!
    var targetAudience: [String]!
    var solutions: [Solution]!
    var costPerUser: String!
    var maxParticipantsCount: Int!
    var totalCost: String!
    var respondentsCount: Int!
    
}
