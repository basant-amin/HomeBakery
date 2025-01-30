//
//  SignUp.swift
//  HomeBakery
//
//  Created by basant amin bakir on 29/01/2025.
//

import SwiftUI

struct SignUp: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightGrays.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Text("Sign Up")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .padding(.top, 20)
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Name")
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                                .background(Color.white)
                                .frame(width: 358, height: 50)
                            TextField("Name", text: $name)
                                .frame(width: 350, height: 50)
                                .padding(5)
                                .cornerRadius(8)
                        }
                        
                        Text("Email")
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                                .background(Color.white)
                                .frame(width: 358, height: 50)
                            TextField("Email", text: $email)
                                .frame(width: 350, height: 50)
                                .padding(5)
                                .cornerRadius(8)
                        }
                        
                        Text("Password")
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                                .background(Color.white)
                                .frame(width: 358, height: 50)
                            SecureField("Password", text: $password)
                                .frame(width: 350, height: 50)
                                .padding(5)
                                .cornerRadius(8)
                        }
                    }
                    
                    Button {
                        Task {
                            await signUpUser()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(width: 350, height: 20)
                                .padding()
                        } else {
                            Text("Sign Up")
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
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func signUpUser() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            message = "fill all field please"
            return
        }
        
        isLoading = true
        message = ""
        
        let newUser = UserFields(
            id: UUID().uuidString,
            name: name,
            email: email,
            password: password
        )
        
        do {
            let createdUser = try await FetchData().createUser(newUserData: newUser)
            DispatchQueue.main.async {
                message = "creating user was successfull: \(createdUser.fields.name)"
                isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                message = "field create usser: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

#Preview {
    SignUp()
}
