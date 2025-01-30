//
//  MainTabView.swift
//  HomeBakery
//
//  Created by basant amin bakir on 30/01/2025.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomePage()
            }
            .tabItem {
                Image("Logo")
                    .renderingMode(.template)
                
                Text("Bake")
            }

            NavigationStack {
                Courses()
            }
            .tabItem {
                Image("Layer")
                    .renderingMode(.template)
                Text("Courses")
            }

            NavigationStack {
                Profile()
            }
            .tabItem {
                Image("profile")
                    .renderingMode(.template)
                Text("Profile")
            }
        }
        .accentColor(.brown)
    }
}
#Preview {
    MainTabView()
}
