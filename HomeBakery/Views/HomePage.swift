//
//  HomePage.swift
//  HomeBakery
//
//  Created by basant amin bakir on 19/01/2025.
//

import SwiftUI

struct HomePage: View {
    @State private var searchText = ""
    @State private var courses: [CourseRecord] = []
    @State private var isLoading = false
    private var fetchData = FetchData()
    private var filteredCourses: [CourseRecord] {
        if searchText.isEmpty {
            return courses
        } else {
            return courses.filter { course in
                course.fields.title.localizedCaseInsensitiveContains(searchText) ||
                course.fields.level.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Upcoming")
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 100)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                    HStack {
                        VStack {
                            Text("Dec")
                                .fontWeight(.bold)
                            Text("15")
                                .fontWeight(.semibold)
                        }

                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                            .frame(width: 4, height: 60)

                        VStack(alignment: .leading) {
                            Text("Babka Dough")
                                .fontWeight(.bold)

                            HStack {
                                Image(systemName: "location.north")
                                Text("Riyadh, Alnarjis")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            HStack {
                                Image(systemName: "hourglass")
                                Text("4:00 PM")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .padding()

                VStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    } else if courses.isEmpty {
                        Text("No courses available.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredCourses) { course in
                                NavigationLink(destination: CourseDetails(course: course)) {
                                    HStack {
                                        AsyncImage(url: URL(string: course.fields.imageURL)) { image in
                                            image.resizable().scaledToFit()
                                        } placeholder: {
                                            Image(systemName: "photo")
                                        }
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(10)

                                        VStack(alignment: .leading) {
                                            Text(course.fields.title)
                                                .font(.headline)

                                            Text(course.fields.level)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .padding(5)
                                                .background(Color.accentColor.opacity(0.2))
                                                .cornerRadius(5)

                                            HStack {
                                                Image(systemName: "hourglass")
                                                Text("\(Int((course.fields.endDate - course.fields.startDate) / 3600))h")
                                            }
                                            .font(.subheadline)

                                            HStack {
                                                Image(systemName: "calendar")
                                                Text("\(Date(timeIntervalSince1970: course.fields.startDate), style: .date)")
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
                    loadCourses()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("Home Bakery")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding()
                        
                        Divider()
                    }
                }
            }
            .searchable(text: $searchText)
        }
    }

    func loadCourses() {
        isLoading = true
        Task {
            do {
                courses = try await fetchData.fetchCourses()
            } catch {
                print("❌ Error loading courses: \(error)")
            }
            isLoading = false
        }
    }
}

#Preview {
    HomePage()
}
