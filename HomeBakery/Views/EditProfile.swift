//
//  EditProfile.swift
//  HomeBakery
//
//  Created by basant amin bakir on 21/01/2025.
//

import SwiftUI

struct EditProfile: View {
    @AppStorage("userId") private var userId: String?
    let fetchData = FetchData()

    @Binding var userName: String?
    @Binding var bookedCourses: [(bookingId: String, course: CourseRecord)]

    @State private var newUserName: String = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss 
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
                            
                            TextField("Enter your name", text: $newUserName)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)

                            Spacer()

                            Button(action: {
                                Task {
                                    await updateUserName()
                                }
                            }) {
                                Text("Done")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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

                    List {
                        ForEach(bookedCourses, id: \.bookingId) { booking in
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
                        .onDelete { indexSet in
                            Task {
                                await deleteBooking(at: indexSet)
                            }
                        }
                    }
                    .padding(.top, -30)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 0) {
                            Text("Edit Profile")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding()

                            Divider()
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await fetchUserName()
            }
        }
    }

    func fetchUserName() async {
        guard let userId = userId else { return }

        do {
            let users = try await fetchData.fetchUsers()
            if let user = users.first(where: { $0.id == userId || $0.fields.id == userId }) {
                DispatchQueue.main.async {
                    self.newUserName = user.fields.name
                }
            }
        } catch {
            print("❌ Error fetching user: \(error)")
        }
    }

    func updateUserName() async {
        guard let userId = userId, !newUserName.isEmpty else { return }

        do {
            let users = try await fetchData.fetchUsers()
            guard let user = users.first(where: { $0.id == userId || $0.fields.id == userId }) else {
                print("❌ User not found")
                return
            }

            let updatedData = UserFields(
                id: userId,
                name: newUserName,
                email: user.fields.email,
                password: user.fields.password
            )

            let updatedUser = try await fetchData.updateUser(userId: userId, updatedUserData: updatedData)
            
            DispatchQueue.main.async {
                self.userName = updatedUser.fields.name
                dismiss()
            }
        } catch {
            print("❌ Error updating user: \(error)")
        }
    }

   
    func deleteBooking(at offsets: IndexSet) async {
        for index in offsets {
            let bookingId = bookedCourses[index].bookingId
            do {
                try await fetchData.deleteBooking(bookingId: bookingId)
                DispatchQueue.main.async {
                    bookedCourses.remove(atOffsets: offsets) 
                }
            } catch {
                print("❌ Error deleting booking: \(error)")
            }
        }
    }
}

//#Preview {
//    @State var mockUserName: String? = "Test User"
//    @State var mockBookedCourses: [(bookingId: String, course: CourseRecord)] = [
//        (bookingId: "booking1", course: CourseRecord(
//            id: "course1",
//            createdTime: "2025-01-07T22:40:48.000Z",
//            fields: CourseFields(
//                id: "course1",
//                title: "Banana Bread",
//                imageURL: "https://i.imgur.com/w2CXHgV.png",
//                level: "Beginner",
//                locationName: "New York",
//                locationLatitude: 40.7128,
//                locationLongitude: -74.0060,
//                chefID: "chef1",
//                startDate: 1734028800,
//                endDate: 1734036000,
//                description: "Learn to bake moist, flavorful banana bread."
//            )
//        ))
//    ]
//
//    return EditProfile(userName: $mockUserName, bookedCourses: $mockBookedCourses)
//}
