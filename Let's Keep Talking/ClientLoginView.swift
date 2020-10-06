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
    @State private var genderPref: String = ""
    
    @State private var ethnicity: String = ""
    @State private var ethnicOptOut: Bool = false
    @State private var bme: Bool = false
    @State private var ethnicPref: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var formError: String = ""
    
    @State private var loginError: Bool = false
    @State private var loginErrorText: String = ""
    
    @State private var loginDetails: LoginStruct = LoginStruct(phoneNo: "", password: "")
    @State private var createAccDetails: CreateAccStruct = CreateAccStruct(phoneNo: "", password: "", gender: "", genderPref: "", ethnicity: "", ethnicPref: false)
    
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
                    
                    Spacer()
                    
                    CreateAccFormView(fullName: $fullName, phoneNo: $phoneNo, phoneConf: $phoneConf, password: $password, passwordConf: $passwordConf, gender: $gender, genderOptOut: $genderOptOut, genderPref: $genderPref, ethnicity: $ethnicity, ethnicOptOut: $ethnicOptOut, bme: $bme, ethnicPref: $ethnicPref, showHelp: false)
                    
                    
                } else {
                    
                    TextField("Phone Number", text: $phoneNo)
                        .padding()
                        .keyboardType(.numberPad)
                    
                    SecureField("Password", text: $password)
                        .padding()
                }
                
                
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
            
            switch response.result {
            case let .success(value):
                if let JSON = value as? [String: Any] {
                    
                    if let status = JSON["status"] as? Bool {
                        if(status) {
                            if let client = JSON["result"] as? [String: Any] {
                                handleNetworkResponse(true, "", client)
                            } else {
                                handleNetworkResponse(false, "Error \(#line)", NSNull())
                            }
                        } else {
                            if let error = JSON["error"] as? String {
                                if(error.elementsEqual("ExistingUserError")) {
                                    handleNetworkResponse(false, "A User with phone number already exists. Please sign in or contact support", NSNull())
                                }
                            } else {
                                handleNetworkResponse(false, "Error \(#line)", NSNull())
                            }
                        }
                    } else {
                        handleNetworkResponse(false, "Error \(#line)", NSNull())
                    }
                } else {
                    handleNetworkResponse(false, "Error \(#line)", NSNull())
                }
            case let .failure(error):
                handleNetworkResponse(false, "Network Error \(#line)", error)
            }
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
                                handleNetworkResponse(true, "", client)
                            } else {
                                handleNetworkResponse(false, "Error \(#line)", NSNull())
                            }
                        } else {
                            if let error = JSON["error"] as? String {
                                if(error.elementsEqual("IncorrectPassword")) {
                                    handleNetworkResponse(false, "Incorrect Password. Please try again", NSNull())
                                } else if(error.elementsEqual("NoUser")) {
                                    handleNetworkResponse(false, "No user exists with that phone number, please create an account", NSNull())
                                }
                            } else {
                                handleNetworkResponse(false, "Error \(#line)", NSNull())
                            }
                        }
                    }
                } else {
                    handleNetworkResponse(false, "Error \(#line)", NSNull())
                }
                
                
                
            case let .failure(error):
                handleNetworkResponse(false, "Network Error \(#line)", error)
            }
        }
    }
    
    
    func handleNetworkResponse(_ status: Bool, _ message: String, _ result: Any?) -> Void{
        if(status) {
            
            
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.set("client", forKey: "userType")
            
            if let client = result as? [String: Any] {
                UserDefaults.standard.set(client["_id"], forKey: "id")
                UserDefaults.standard.set(!(client["calls"] as! [Any]).isEmpty, forKey: "hasCalls")
                
                isLoggedIn = true
            } else {
                handleNetworkResponse(false, "Error \(#line)", NSNull())
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
