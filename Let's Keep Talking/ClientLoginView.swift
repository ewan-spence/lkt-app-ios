//
//  ClientLoginView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 19/09/2020.
//

import SwiftUI

import Alamofire

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
                    .padding(.trailing)
                    
                }
                
                Spacer()
                
                if(!formError.isEmpty){
                    Text(formError)
                        .foregroundColor(.red)
                        .font(.headline)
                }
                
                if(isOn) {
                    HStack{
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
                
                Button(action: onClick, label: {
                    if(isOn) {
                        Text("Create Account")
                    } else {
                        Text("Sign in")
                    }
                })
                .padding()
                
                Spacer()
            }
            
            if(isLoading){
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
                return
            } else if(!password.elementsEqual(passwordConf)){
                formError = "Passwords do not match"
                return
            }
        }
        
        if(isValidForm(requiredFields)) {
            
            if(isOn){
                let url = APIEndpoints.CREATE_ACC
                
                let parameters = CreateStruct(phoneNo: phoneNo, password: password, gender: gender, genderPref: genderPref, ethnicity: ethnicity, ethnicPref: ethnicPref)
                
                AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).response { response in
                    debugPrint(response)
                }
            } else {
                let url = APIEndpoints.CLIENT_LOGIN
                
                let parameters = LoginStruct(phoneNo: phoneNo, password: password)
                
                AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).response { response in
                    debugPrint(response)
                }
            }
        }
        
        isLoading = false
    }
    
    func isValidForm(_ requiredFields: [String]) -> Bool {
        for field in requiredFields {
            if(field.isEmpty) {
                return false
            }
        }
        return true
    }
}

struct LoginStruct: Encodable {
    let phoneNo: String
    let password: String
}

struct CreateStruct: Encodable {
    let phoneNo: String
    let password: String
    let gender: String
    let genderPref: Bool
    let ethnicity: String
    let ethnicPref: Bool
}

struct ClientLoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ClientLoginView()
        }
    }
}
