//
//  HomeBakerrModel.swift
//  HomeBakery
//
//  Created by basant amin bakir on 21/01/2025.
//

import Foundation


struct ChefRecord: Identifiable, Codable {
    let id: String
    let createdTime: String
    let fields: ChefFields
}

struct ChefFields: Codable {
    let id: String
    let name: String
    let email: String
    let password: String
}
struct ChefResponse: Codable {
    let records: [ChefRecord]
}

struct UserRecord: Identifiable, Codable {
    let id: String
    let createdTime: String
    let fields: UserFields
}

struct UserFields: Codable {
    let id: String?
    let name: String
    let email: String?
    let password: String?
}

struct CourseRecord: Identifiable, Codable {
    let id: String
    let createdTime: String
    let fields: CourseFields
}

struct CourseFields: Codable {
    let id: String
    let title: String
    let imageURL: String
    let level: String
    let locationName: String
    let locationLatitude: Double
    let locationLongitude: Double
    let chefID: String
    let startDate: Double
    let endDate: Double
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "image_url"
        case level
        case locationName = "location_name"
        case locationLatitude = "location_latitude"
        case locationLongitude = "location_longitude"
        case chefID = "chef_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case description
    }
}

struct BookingRecord: Identifiable, Codable {
    let id: String
    let createdTime: String
    let fields: BookingFields
}
struct BookingFields: Codable {

    let userId: String
    let courseId: String
    let status: String
    enum CodingKeys: String, CodingKey {
    
        case userId = "user_id"
        case courseId = "course_id"
        case status
    }
 
}
