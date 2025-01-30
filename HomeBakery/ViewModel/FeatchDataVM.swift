//
//  DataViewModel.swift
//  HomeBakery
//
//  Created by basant amin bakir on 22/01/2025.
//

import Foundation

struct FetchData {
    enum FetchError: Error {
        case badResponse
    }
    let baseURL = URL(string: "https://api.airtable.com/v0/appXMW3ZsAddTpClm/")!
    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"
    
    func fetchChefs() async throws -> [ChefRecord] {
        let chefUrl = baseURL.appendingPathComponent("chef")
             var request = URLRequest(url: chefUrl)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        let chefResponse = try JSONDecoder().decode(AirtableResponse<ChefRecord>.self, from: data)
        
        return chefResponse.records
    }
    
    func fetchChefById(chefId: String) async throws -> ChefRecord? {
        let chefUrl = baseURL.appendingPathComponent("chef")
        var request = URLRequest(url: chefUrl)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchError.badResponse
        }

        let chefResponse = try JSONDecoder().decode(AirtableResponse<ChefRecord>.self, from: data)

        return chefResponse.records.first(where: { $0.fields.id == chefId })
    }

    func fetchUsers() async throws -> [UserRecord] {
        let userUrl = baseURL.appendingPathComponent("user")
        var request = URLRequest(url: userUrl)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📝 User API Response: \(jsonString)")
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchError.badResponse
        }

        let userResponse = try JSONDecoder().decode(AirtableResponse<UserRecord>.self, from: data)
        return userResponse.records
    }
    
    func fetchUserById(userId: String) async throws -> UserRecord? {
        let userUrl = baseURL.appendingPathComponent("user")
        var request = URLRequest(url: userUrl)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        // ✅ Debugging: Print the entire JSON response before decoding
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📝 User API Response: \(jsonString)")
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchError.badResponse
        }

        let userResponse = try JSONDecoder().decode(AirtableResponse<UserRecord>.self, from: data)

        // ✅ Look for the correct user in `id` field
        if let foundUser = userResponse.records.first(where: { $0.id == userId || $0.fields.id == userId }) {
            print("✅ Found User: \(foundUser.fields.name)")
            return foundUser
        } else {
            print("❌ No user found with ID: \(userId)")
            return nil
        }
    }

    func updateUser(userId: String, newName: String) async throws -> Bool {
        let updateUrl = baseURL.appendingPathComponent("user/\(userId)")
        var request = URLRequest(url: updateUrl)
        request.httpMethod = "PATCH" // ✅ استخدام PATCH لتحديث الحقل المحدد فقط
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updateData: [String: Any] = ["fields": ["name": newName]]
        let jsonData = try JSONSerialization.data(withJSONObject: updateData, options: [])
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("❌ API Error: \(response)")
            return false
        }

        print("✅ User updated successfully: \(String(data: data, encoding: .utf8) ?? "")")
        return true
    }
    
    func fetchCourses() async throws -> [CourseRecord] {
    let courseUrl = baseURL.appendingPathComponent("course")
    var request = URLRequest(url: courseUrl)
    request.setValue(token, forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw FetchError.badResponse
    }
    
    print("Raw Data: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
    
    let courseResponse = try JSONDecoder().decode(AirtableResponse<CourseRecord>.self, from: data)
    return courseResponse.records
}
    
    func fetchBooking() async throws -> [BookingRecord] {
        let bookingUrl = baseURL.appendingPathComponent("booking")
        var request = URLRequest(url: bookingUrl)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        print("Raw Data: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")

        let bookingResponse = try JSONDecoder().decode(AirtableResponse<BookingRecord>.self, from: data)
        return bookingResponse.records
    }
    
    func fetchCourses(by courseIds: [String]) async throws -> [CourseRecord] {

        let allCourses = try await fetchCourses()
        let filteredCourses = allCourses.filter { courseIds.contains($0.fields.id) }


        return filteredCourses
    }

    func fetchBookings(for userId: String) async throws -> [BookingRecord] {

        let allBookings = try await fetchBooking()
        
        let userBookings = allBookings.filter { $0.fields.userId == userId }
        

        return userBookings
    }
     
    func bookCourse(courseId: String, userId: String) async throws -> BookingRecord {
        let bookingUrl = baseURL.appendingPathComponent("booking")
        var request = URLRequest(url: bookingUrl)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let bookingData = BookingFields(userId: userId, courseId: courseId, status: "Confirmed")
        let requestBody = ["fields": bookingData]

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw FetchError.badResponse
            }

            let bookedCourse = try JSONDecoder().decode(BookingRecord.self, from: data)
            return bookedCourse
        } catch {
            throw error
        }
    }
    
    func deleteBooking(bookingId: String) async throws {
         let deleteUrl = baseURL.appendingPathComponent("booking/\(bookingId)")
         var request = URLRequest(url: deleteUrl)
         request.httpMethod = "DELETE"
         request.setValue(token, forHTTPHeaderField: "Authorization")

         let (_, response) = try await URLSession.shared.data(for: request)
         guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
             throw FetchError.badResponse
         }

         print("✅ Successfully deleted booking with ID: \(bookingId)")
     }

    func updateUser(userId: String, updatedUserData: UserFields) async throws -> UserRecord {
        let updateUrl = baseURL.appendingPathComponent("user/\(userId)")
        var request = URLRequest(url: updateUrl)
        request.httpMethod = "PUT"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = ["fields": updatedUserData]
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let updatedUser = try JSONDecoder().decode(UserRecord.self, from: data)
        return updatedUser
    }

    func createUser(newUserData: UserFields) async throws -> UserRecord {
        let createUserUrl = baseURL.appendingPathComponent("user")
        
        var request = URLRequest(url: createUserUrl)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = ["fields": newUserData]
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let createdUser = try JSONDecoder().decode(UserRecord.self, from: data)
        return createdUser
    }

    func fetchUserByEmail(email: String) async throws -> UserRecord? {
        let userUrl = baseURL.appendingPathComponent("user")
        var request = URLRequest(url: userUrl)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔍 JSON Response: \(jsonString)")
        } else {
            print("⚠️ Received data but couldn't convert to string.")
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchError.badResponse
        }

        do {
            let userResponse = try JSONDecoder().decode(AirtableResponse<UserRecord>.self, from: data)
            
            let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

            return userResponse.records.first {
                guard let userEmail = $0.fields.email?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
                    print("⚠️ User missing email field: \(String(describing: $0.fields))")
                    return false
                }
                return userEmail == normalizedEmail
            }
        } catch {
            print("❌ JSON Decoding Error: \(error)")
            throw error
        }
    }

    
}
struct AirtableResponse<T: Codable>: Codable {
    let records: [T]
}

