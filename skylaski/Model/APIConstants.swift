//
//  APIConstants.swift
//  PPE
//
//  Created by Anilkumar on 20/04/21.
//

import UIKit

struct APPURL {
    private struct Domain {
        // dev
        static let baseURL = "https://www1.skylaski.com/"
        static let baseApiURL = "https://wgm1.skylaski.com/"
        
        // production
        static let baseLiveURL = "https://www.skylaski.com/"
        static let baseLiveApiURL = "https://wgm.skylaski.com/"
    }
    
    //**************************   PRODUCTION   ************************************//
    static let domain = Domain.baseLiveURL // web
    static let domainAPi = Domain.baseLiveApiURL // api's
    
    //**************************   DEVELOPMENT   ************************************//
//    static let domain = Domain.baseURL // web
//    static let domainAPi = Domain.baseApiURL // api's
}

struct endPoint {
    static let client = "api/0.1/client/index.php"
    static let user = "api/0.1/user/index.php"
    static let login = "sign-in"
    static let googleLogin = "sign-in/google-mobile.php"
    static let checkIp = "checkip"
    static let payment = "applepay/payment_api/verifyReceipt.php"
}

struct cmdType  {
    static let create = "create_client"
    static let client_config = "get_client_config"
    static let locations = "get_locations"
    static let dns = "get_dns"
    static let plan = "get_plan"
    static let attachLocation = "attach_location"
    static let detachLocation = "detach_location"
    static let deleteClient = "delete_client"
}



struct ErrorMessage {
    static let noInternet = "Sorry, we can't connect right now. Please check your internet connection and try again."
}
