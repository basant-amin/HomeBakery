//
//  CourseDetails.swift
//  HomeBakery
//
//  Created by basant amin bakir on 20/01/2025.
//

import SwiftUI
import MapKit

struct CourseDetails: View {
    let course: CourseRecord
    @State private var showSignInSheet: Bool = false
    @State private var isLoading: Bool = false
    @State private var message: String = ""
    @State private var chef: ChefRecord?

    @AppStorage("userId") private var userId: String?
    let academy = CLLocationCoordinate2D(latitude: 24.862043433690506, longitude: 46.725397030975635)
    private var courseLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: course.fields.locationLatitude, longitude: course.fields.locationLongitude)
    }

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: course.fields.imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else if phase.error != nil {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.lightGrays)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    ProgressView()
                        .frame(height: 200)
                }
            }

            VStack(alignment: .leading) {
                Text("About the course")
                    .font(.headline)

                Text(course.fields.description)
                    .font(.caption)
                    .padding(.bottom, 10)

                Divider()

                HStack {
                    Text("Chef:")
                    if let chef = chef {
                        Text(chef.fields.name)
                            .font(.caption)
                            .fontWeight(.bold)
                    } else {
                        Text("Loading...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Text(course.fields.level)
                        .background(Color.accentColor.opacity(0.3))
                    Spacer()
                    Text("Duration: 2h")
                }

                HStack {
                    HStack {
                        Text("Date & Time:")
                        Text("15 Dec - 4:00 PM")
                            .font(.caption)
                    }
                    Spacer()
                    Text("Location: \(course.fields.locationName)")

                }

                Map {
                    Marker(course.fields.locationName, coordinate: courseLocation)
                }

            }.onAppear {
                Task {
                    do {
                        let fetchedChef = try await FetchData().fetchChefById(chefId: course.fields.chefID)
                        DispatchQueue.main.async {
                            self.chef = fetchedChef
                        }
                    } catch {
                        print("❌ Error fetching chef: \(error)")
                    }
                }
            }

            .padding()

            Button {
                if let userId = userId, !userId.isEmpty {
                    Task {
                        await bookNow(userId: userId)
                    }
                } else {
                    showSignInSheet.toggle()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(width: 350, height: 20)
                        .padding()
                } else {
                    Text("Book Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 350, height: 20)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
            .padding()

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(message.contains("Done") ? .green : .red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .sheet(isPresented: $showSignInSheet) {
            SignIn(onLoginSuccess: { userId in
                self.userId = userId
            })
        }
    }

    private func bookNow(userId: String) async {
        isLoading = true
        message = ""

        do {
            let booking = try await FetchData().bookCourse(courseId: course.fields.id, userId: userId)
            DispatchQueue.main.async {
                message = "Sucsess booked course"
                isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                message = "Faild to book course: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}


#Preview {
    let sampleCourse = CourseRecord(
        id: "1",
        createdTime: "2025-01-01T00:00:00Z",
        fields: CourseFields(
            id: "1",
            title: "Sample Course",
            imageURL: "https://via.placeholder.com/150",
            level: "Intermediate",
            locationName: "Riyadh",
            locationLatitude: 24.7136,
            locationLongitude: 46.6753,
            chefID: "1",
            startDate: 1672520400.0,
            endDate: 1672524000.0,
            description: "This is a sample course description."
        )
    )
    CourseDetails(course: sampleCourse)
}
