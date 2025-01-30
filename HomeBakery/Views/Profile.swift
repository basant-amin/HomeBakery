//
//  Profile.swift
//  HomeBakery
//
//  Created by basant amin bakir on 19/01/2025.
//

import SwiftUI

struct Profile: View {
    @AppStorage("userId") var userId: String?
    @AppStorage("userEmail") private var userEmail: String? 

    let fetchData = FetchData()

    @State private var bookedCourses: [(bookingId: String, course: CourseRecord)] = []
    @State private var isLoading: Bool = false
    @State private var userName: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightGrays.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(height: 70)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.black)
                                .background(Color.accentColor.opacity(0.2))
                                .font(.system(size: 40))

                            Text(userName ?? "Basant Amiiin")
                                .font(.headline)

                            Spacer()

                            NavigationLink(destination: EditProfile(userName: $userName, bookedCourses: $bookedCourses)) {
                                Text("Edit")
                            }
                        }
                        .padding()
                    }
                    .padding()

                    Divider()

                    VStack(alignment: .leading) {
                        Text("Booked Courses")
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                    if isLoading {
                        ProgressView("Loading booked courses...")
                        Spacer()
                    } else if bookedCourses.isEmpty {
                        Text("No bookings available")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    } else {
                        List(bookedCourses, id: \.bookingId) { booking in
                            HStack {
                                AsyncImage(url: URL(string: booking.course.fields.imageURL)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Image(systemName: "photo")
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)

                                VStack(alignment: .leading) {
                                    Text(booking.course.fields.title)
                                        .font(.headline)

                                    Text(booking.course.fields.level)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(5)
                                        .background(Color.accentColor.opacity(0.2))
                                        .cornerRadius(5)

                                    HStack {
                                        Image(systemName: "hourglass")
                                        Text("\(Int((booking.course.fields.endDate - booking.course.fields.startDate) / 3600))h")
                                    }
                                    .font(.subheadline)

                                    HStack {
                                        Image(systemName: "calendar")
                                        Text("\(Date(timeIntervalSince1970: booking.course.fields.startDate), style: .date)")
                                    }
                                    .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await fetchUserName()
                await loadUserBookings()
                print("🟡 Stored userEmail in @AppStorage: \(userEmail ?? "nil")")

            }
        }
    }

    func fetchUserName() async {
        guard let email = userEmail, !email.isEmpty else {
            print("❌ No userEmail found in @AppStorage")
            DispatchQueue.main.async {
                self.userName = "Basant"
            }
            return
        }

        print("🟢 Fetching user with email: \(email)")

        do {
            let user = try await fetchData.fetchUserByEmail(email: email)
            DispatchQueue.main.async {
                if let user = user {
                    print("✅ User found: \(user.fields.name)")
                    self.userName = user.fields.name
                } else {
                    print("❌ No user found for email: \(email)")
                    self.userName = "Guest"
                }
            }
        } catch {
            print("❌ Error fetching user: \(error)")
        }
    }


    func loadUserBookings() async {
        guard let userId = userId, !userId.isEmpty else {
            return
        }

        isLoading = true
        do {
            let bookings = try await fetchData.fetchBookings(for: userId)

            if bookings.isEmpty {
            } else {
                let courseIds = bookings.map { $0.fields.courseId }
                let courses = try await fetchData.fetchCourses(by: courseIds)

                let bookingsWithCourses = bookings.compactMap { booking -> (String, CourseRecord)? in
                    if let course = courses.first(where: { $0.fields.id == booking.fields.courseId }) {
                        return (booking.id, course)
                    }
                    return nil
                }

                DispatchQueue.main.async {
                    bookedCourses = bookingsWithCourses
                    isLoading = false
                }
            }
        } catch {
            isLoading = false
        }
    }
}

#Preview {
    Profile()
}
