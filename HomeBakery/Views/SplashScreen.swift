//
//  ContentView.swift
//  HomeBakery
//
//  Created by basant amin bakir on 19/01/2025.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive: Bool = false
    var body: some View {
    
        if isActive{
            MainTabView()
        }else {
            ZStack{
                Color(.lightGrays)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("logo-p")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding(.bottom,5)
                    Text("Home Bakery")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.brownPrimary)
                    Text("Baked to perfection")
                        .font(.caption)
                        .foregroundColor(.brownPrimary)
                }
                
            }.onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation{
                        self.isActive = true
                    }
                    
                }
            }
        }
        
    }
}
#Preview {
    SplashScreen()
}
