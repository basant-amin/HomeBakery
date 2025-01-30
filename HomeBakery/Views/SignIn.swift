//
//  SignIn.swift
//  HomeBakery
//
//  Created by basant amin bakir on 21/01/2025.
//

import SwiftUI

struct SignIn: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false 
    
    var onLoginSuccess: (String) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightGrays.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Text("Sign In")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        Spacer()
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
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
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        Text("Password")
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                                .background(Color.white)
                                .frame(width: 358, height: 50)
                            SecureField("Password", text: $password)
                                .frame(width: 350, height: 50)
                                .cornerRadius(10)
                        }
                    }
                    
                    Button {
                        Task {
                            await signIn()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(width: 350, height: 20)
                                .padding()
                        } else {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 350, height: 20)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    HStack {
                              Text("Don't have an account?")
                                  .foregroundColor(.gray)
                              NavigationLink(destination: SignUp()) {
                                  Text("Sign Up")
                                      .foregroundColor(.accent)
                                      .fontWeight(.bold)
                              }
                          }
                          .padding(.top, 10)
                    Spacer()
                }
            }
        }
    }
    
    private func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            showError = true
            errorMessage = "Email and password cannot be empty."
            return
        }

        isLoading = true
        showError = false

        do {
            let fetchData = FetchData()
            if let userRecord = try await fetchData.fetchUserByEmail(email: email) {

                guard let storedPassword = userRecord.fields.password else {
                    throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "❌ User record is missing a password field."])
                }

                if storedPassword == password {
                    DispatchQueue.main.async {
                        onLoginSuccess(userRecord.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password."])
                }
            } else {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found in database."])
            }
        } catch let decodingError as DecodingError {
            DispatchQueue.main.async {
                showError = true
                errorMessage = "⚠️ JSON Decoding Error: \(decodingError.localizedDescription)"
                isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                showError = true
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }



}

#Preview {
    SignIn { userId in
        print("User logged in with ID: \(userId)")
    }
}
