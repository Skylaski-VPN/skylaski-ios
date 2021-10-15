//
//  AppModel.swift
//  skylaski
//
//  Created by Anilkumar on 21/05/21.
//

import UIKit

//MARK:- Common
struct ApiResponse :Codable {
    var status: String?
    var message: String?
    var success: Bool?
    var result: resultResponse?
}
struct resultResponse :Codable{
    var client_uid: String?
    var client_token: String?
    var max_clients: Bool?
    var config: String?
    var dns_server: String?
}

struct ApiSuccessResponse :Codable {
    var status: String?
    var message: String?
    var success: Bool?
}
//MARK:- location
struct DeLcoationResponse :Codable {
    var status: String?
    var message: String?
    var success: Bool?
    var result: String?
}


struct LcoationResponse :Codable {
    var status: String?
    var message: String?
    var success: Bool?
    var result: [locationResponse]?
}
struct locationResponse :Codable{
    var name: String?
    var loc_uid: String?
}


//MARK:- Plans

struct PlanResponse :Codable {
    var status: String?
    var message: String?
    var success: Bool?
    var result: PlanResultData?
}
struct PlanResultData :Codable{
    var product: ProductData?
    var plan: PlanData?
}

struct ProductData :Codable{
    var id: String?
    var name: String?
    var value: String?
    var description: String?
    var periods: String?
    var period_unit: String?
    var price: String?
    var unique_id: String?
    var created_at: String?
    var updated_at: String?
    var network_id: String?
    var total_users: String?
    var total_clients_per_user: String?
    var type: String?
}

struct PlanData :Codable{
    var id : String?
    var domain_id : String?
    var checkout_id : String?
    var product_id : String?
    var coupon_id : String?
    var total : String?
    var subtotal : String?
    var discounts : String?
    var fees : String?
    var total_users : String?
    var total_clients_per_user : String?
    var expiration : String?
    var created_at : String?
    var updated_at : String?
    var referral_code : String?
    var affiliate_code : String?
    var team_code : String?
}
