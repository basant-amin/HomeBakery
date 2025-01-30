//
//  Courses.swift
//  HomeBakery
//
//  Created by basant amin bakir on 19/01/2025.
//

import SwiftUI

struct Courses: View {
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
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    List {
                        ForEach(filteredCourses) { course in
                            NavigationLink(destination: CourseDetails(course: course)) {
                                HStack {
                                    AsyncImage(url: course.fields.imageURL.isEmpty
                                               ? URL(string: "https://via.placeholder.com/150")!
                                               : URL(string: course.fields.imageURL)!)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                    
                                    VStack(alignment: .leading) {
                                        Text(course.fields.title)
                                            .font(.headline)
                                        Text(course.fields.level)
                                            .background(Color.accentColor.opacity(0.2))
                                        HStack {
                                            Image(systemName: "hourglass")
                                            Text("2h")
                                        }
                                        HStack {
                                            Image(systemName: "calendar")
                                            Text("\(formattedDate(course.fields.startDate))")
                                        }
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("Courses")
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
                print("Error loading courses: \(error)")
            }
            isLoading = false
        }
    }
    
    func formattedDate(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    Courses()
}
