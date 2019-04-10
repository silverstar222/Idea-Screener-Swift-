//
//  Constants.swift
//  Idea Screener
//
//  Created by Silver on 02.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import Foundation
import UIKit

let MAIN_API_URL = "http://apiideascreener-dev.us-east-1.elasticbeanstalk.com/api/v1/"
let SERVER_URL = "" // https://s3.amazonaws.com/api-ideascreener-s3-bucket

// 159.65.206.18

let REGISTRATION_URL = MAIN_API_URL + "auth/registration"
let LOGIN_URL = MAIN_API_URL + "auth/login"
let LOGIN_WITH_GOOGLE_URL = MAIN_API_URL + "auth/google"
let LOGIN_WITH_FACEBOOK_URL = MAIN_API_URL + "auth/facebook"
let FORGOT_PASS_URL = MAIN_API_URL + "auth/forgot"
let PROFILE_URL = MAIN_API_URL + "me"
let PROFILE_UPDATE_URL = MAIN_API_URL + "profile/update"
let USER_UPDATE_URL = MAIN_API_URL + "users/" + CURRENT_USER_ID  //        PUT /api/v1/users/:user_id/
let SURVEYS_URL = MAIN_API_URL + "users/" + CURRENT_USER_ID + "/surveys" // api/v1/users/{user_id}/surveys/{survey_id}
let GET_AVAIBLE_SURVEYS = MAIN_API_URL + "users/" + CURRENT_USER_ID + "/surveys/available" // api/v1/users/:user_id/surveys/available
let SURVEY_ANSWERS_URL = MAIN_API_URL + "users/" // api/v1/users/1/save_survey_answers
let RESPONDED_SURVEYS_URL = MAIN_API_URL + "users/" + CURRENT_USER_ID + "/surveys/my_responded_ideas" // /api/v1/users/:user_id/surveys/my_responded_ideas
let STRIPE_TOKEN_POST_URL = MAIN_API_URL + "charge"
let STRIPE_ACCOUNT_POST_URL = MAIN_API_URL + "accounts"
let STRIPE_EXTERNAL_POST_URL = MAIN_API_URL + "external"

var CURRENT_USER_EMAIL = ""
var CURRENT_USER_ID = ""
var USER_TOKEN = ""
var DEVICE_TOKEN = ""


let STRIPE_PUBLIC_KEY = "pk_test_llREOONlyE5NP7Bv2K3wIRj1"
let STRIPE_SECRET_KEY = "sk_test_yqwvCvKKipu2Qw2CZcFXsgNd"


let GOOGLE_CLIENT_ID = "236043553936-o2oj2odv4vphjkdcg99n2gheo21qfp3a.apps.googleusercontent.com"
let GOOGLE_API = "AIzaSyCIC3uvDDtnOM3_uS4c70TVPtBWDOs7Iqc"

/*
 
 facebook
 app id: 697971903730647
 app secret: 5e35fbe2ca8e8e857db67668366badd6
 Token: b6de24d6e421a76a406c24ac8545b761
 
 */

var notificationStart = false

let respondSurvey = RespondSurvey.shared()

typealias DownloadComplete = (_ result: Bool) -> ()

typealias LoginComplete = (_ result: Bool) -> ()

typealias RegistrationComplete = (_ result: Bool) -> ()

typealias UserProfileComplete = (_ result: Bool, _ userStruct: UserStruct?) -> ()

typealias ProfileUpdateComplete = (_ result: Bool) -> ()

typealias SurveyPostComplete = (_ result: Bool) -> ()

typealias AnswerComplete = (_ result: Bool, _ success:Bool?) -> ()

typealias ImageUpdateComplete = (_ result: Bool) -> ()

typealias UserUpdateComplete = (_ result: Bool) -> ()

typealias StripeTokenComplete = (_ result: Bool) -> ()

typealias CreateCardComplete = () -> ()

typealias CrtUserAccComplete = (_ result: Bool) -> ()

//    func isValidEmail(testStr:String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailTest.evaluate(with: testStr)
//    }

//    func isValidPassword() -> Bool {
//        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()-_=+{}|?>.<,:;~`’]{8,}$"
//
////        ^                         Start anchor
////        (?=.*[A-Z].*[A-Z])        Ensure string has two uppercase letters.
////        (?=.*[!@#$&*])            Ensure string has one special case letter.
////        (?=.*[0-9].*[0-9])        Ensure string has two digits.
////        (?=.*[a-z].*[a-z].*[a-z]) Ensure string has three lowercase letters.
////        .{8}                      Ensure string is of length 8.
////        $                         End anchor.
//
//        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
//        return passwordTest.evaluate(with: self)
//    }




