//
//  ClientLoginView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 19/09/2020.
//

import SwiftUI

import Alamofire
import Foundation


struct ClientLoginView: View {
    @State private var isOn: Bool = false
    
    @State private var fullName: String = ""
    @State private var phoneNo: String = ""
    @State private var phoneConf: String = ""
    @State private var password: String = ""
    @State private var passwordConf: String = ""
    
    @State private var gender: String = ""
    @State private var genderOptOut: Bool = false
    @State private var genderPref: Bool = false
    
    @State private var ethnicity: String = ""
    @State private var ethnicOptOut: Bool = false
    @State private var bme: Bool = false
    @State private var ethnicPref: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var formError: String = ""
    
    @State private var loginError: Bool = false
    @State private var loginErrorText: String = ""
    
    @State private var loginDetails: LoginStruct = LoginStruct(phoneNo: "", password: "")
    @State private var createAccDetails: CreateAccStruct = CreateAccStruct(phoneNo: "", password: "", gender: "", genderPref: false, ethnicity: "", ethnicPref: false)
    
    @Binding var isLoggedIn: Bool
    
    
    var body: some View {
        ZStack{
            
            VStack {
                HStack {
                    
                    Toggle(isOn: $isOn, label: {
                        if(isOn) {
                            Text("Switch to Login").frame(maxWidth: .infinity, alignment: .trailing)
                        } else {
                            Text("Switch to Account Creation").frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    })
                    .disabled(isLoading)
                    .padding(.trailing)
                    
                }
                Spacer()
            }
            VStack {
                
                
                
                Spacer()
                
                if(!formError.isEmpty){
                    Text(formError)
                        .foregroundColor(.red)
                        .font(.headline)
                }
                
                if(isOn) {
                    
                    HStack {
                        Text("* Required")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.leading)
                        
                        Spacer()
                    }
                    TextField("Full Name *", text: $fullName)
                        .padding()
                    
                    
                    TextField("Phone Number *", text: $phoneNo)
                        .padding()
                        .keyboardType(.numberPad)
                    
                    TextField("Confirm Phone Number *", text: $phoneConf)
                        .padding()
                        .keyboardType(.numberPad)
                    
                    
                    SecureField("Password *", text: $password)
                        .padding()
                    
                    SecureField("Confirm Password *", text: $passwordConf)
                        .padding()
                    
                    
                    HStack {
                        TextField("Gender", text: $gender)
                            .padding()
                            .disabled(genderOptOut)
                            .onChange(of: genderOptOut, perform: { value in
                                if(value) {
                                    self.gender = ""
                                }
                            })
                        
                        Spacer()
                        
                        Toggle(isOn: $genderOptOut, label: {
                            Text("Prefer not to Specify")
                                .foregroundColor(.gray)
                        })
                        .padding(.trailing)
                    }
                    
                    if(!gender.isEmpty){
                        Toggle(isOn: $genderPref, label: {
                            Text("I would like a caller of the same gender")
                                .foregroundColor(.gray)
                        })
                        .padding()
                    }
                    
                    HStack {
                        TextField("Ethnicity", text: $ethnicity)
                            .padding()
                            .disabled(ethnicOptOut)
                            .onChange(of: ethnicOptOut, perform: { value in
                                if(value) {
                                    self.ethnicity = ""
                                }
                            })
                        
                        Spacer()
                        
                        Toggle(isOn: $ethnicOptOut, label: {
                            Text("Prefer not to Specify")
                                .foregroundColor(.gray)
                        })
                        .padding(.trailing)
                    }
                    
                    if(!ethnicity.isEmpty){
                        Toggle(isOn: $bme, label: {
                            Text("I identify as an ethnic minority")
                                .foregroundColor(.gray)
                        })
                        .padding()
                        
                        if(bme) {
                            Toggle(isOn: $ethnicPref, label: {
                                Text("I would like an ethnic minority caller")
                                    .foregroundColor(.gray)
                            })
                            .padding()
                        }
                    }
                    
                    
                } else {
                    
                    TextField("Phone Number", text: $phoneNo)
                        .padding()
                        .keyboardType(.numberPad)
                    
                    SecureField("Password", text: $password)
                        .padding()
                }
                
                
                
                Spacer()
            }
            
            VStack {
                
                Spacer()
                Spacer()
                
                Button(action: onClick, label: {
                    if(isOn) {
                        Text("Create Account")
                    } else {
                        Text("Sign in")
                    }
                })
                .padding()
                .alert(isPresented: $loginError) {
                    Alert(title: Text("Error"), message: Text(loginErrorText), dismissButton: .default(Text("Got it!")))
                }
                
                Spacer()
            }
            
            if(isLoading) {
                ProgressView()
            }
            
        }
        
    }
    
    
    
    func onClick() {
        isLoading = true
        var requiredFields = [phoneNo, password]
        if(isOn) {
            requiredFields.append(fullName)
            requiredFields.append(phoneConf)
            requiredFields.append(passwordConf)
            
            
            if(!phoneNo.elementsEqual(phoneConf)) {
                formError = "Phone numbers do not match"
                isLoading = false
                return
            } else if(!password.elementsEqual(passwordConf)){
                formError = "Passwords do not match"
                isLoading = false
                return
            }
        }
        
        if(isValidForm(requiredFields)) {
            
            if(isOn){
                createAcc()
                
            } else {
                login()
            }
        } else {
            formError = "Please fill all required fields"
            isLoading = false
        }
    }
    
    func isValidForm(_ requiredFields: [String]) -> Bool {
        for field in requiredFields {
            if(field.isEmpty) {
                return false
            }
        }
        return true
    }
    
    func createAcc() {
        let url = APIEndpoints.CREATE_ACC
        
        let parameters = CreateAccStruct(phoneNo: phoneNo, password: password, gender: gender, genderPref: genderPref, ethnicity: ethnicity, ethnicPref: ethnicPref)
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseJSON { response in
        }
    }
    
    func login() -> Void{
        let url = APIEndpoints.CLIENT_LOGIN
        
        loginDetails = LoginStruct(phoneNo: phoneNo, password: password)
        
        AF.request(url, method: .post, parameters: loginDetails, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                
                // Try casting the response to a JSON
                if let JSON = value as? [String: Any] {
                    
                    // Try casting the "status" field to a boolean (if this fails, the response is from AWS, not the API)
                    if let status = JSON["status"] as? Bool {
                        
                        if(status) {
                            if let client = JSON["result"] as? [String: Any] {
                                handleLoginResponse(true, "", client)
                            } else {
                                handleLoginResponse(false, "Error \(#line)", NSNull())
                            }
                        } else {
                            if let error = JSON["error"] as? String {
                                if(error.elementsEqual("IncorrectPassword")) {
                                    handleLoginResponse(false, "Incorrect Password. Please try again", NSNull())
                                } else if(error.elementsEqual("NoUser")) {
                                    handleLoginResponse(false, "No user exists with that phone number, please create an account", NSNull())
                                }
                            } else {
                                handleLoginResponse(false, "Error \(#line)", NSNull())
                            }
                        }
                    }
                } else {
                    handleLoginResponse(false, "Error \(#line)", NSNull())
                }
                
                
                
            case let .failure(error):
                handleLoginResponse(false, "Network Error \(#line)", error)
            }
        }
    }
    
    
    func handleLoginResponse(_ status: Bool, _ message: String, _ result: Any?) -> Void{
        if(status) {
            if let client = result as? [String: Any] {
                // TODO: Add keychain support

                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.set("client", forKey: "userType")
                
                UserDefaults.standard.set(client["_id"], forKey: "id")
                
                isLoggedIn = true
            }
        } else {
            loginError = true
            loginErrorText = message
        }
        isLoading = false
    }
}

struct ClientLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ClientLoginView(isLoggedIn: .constant(false))
    }
}
