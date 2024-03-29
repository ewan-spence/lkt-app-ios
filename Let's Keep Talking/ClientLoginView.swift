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
    @State var isOn: Bool = false
    
    @State var hasDetailsSaved: Bool
    
    @State var fullName: String = ""
    @State var phoneNo: String = ""
    @State var phoneConf: String = ""
    @State var password: String = ""
    @State var passwordConf: String = ""
    
    @State var gender: String = ""
    @State var genderOptOut: Bool = false
    @State var genderPref: String = ""
    
    @State var ethnicity: String = ""
    @State var ethnicOptOut: Bool = false
    @State var bme: Bool = false
    @State var ethnicPref: Bool = false
    
    @State var isLoading: Bool = false
    @State var formError: String = ""
    
    @State var loginError: Bool = false
    @State var loginErrorText: String = ""
    
    @Binding var calls: [[String: String]]?    
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
                    
                    SecureFieldToggle("Password", text: $password)
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
                .disabled(isLoading)
                
                Spacer()
                
            }
            
            if(isLoading) {
                ProgressView()
            }
            
        }.onAppear(perform: {
            if(hasDetailsSaved) {
                phoneNo = UserDefaults.standard.string(forKey: "phoneNo") ?? ""
                password = UserDefaults.standard.string(forKey: "password") ?? ""
            }
            
            if(!(phoneNo.isEmpty || password.isEmpty)) {
                onClick()
            }
        })
        
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
                let devToken = UserDefaults.standard.string(forKey: "devToken")

                let createAccStruct = CreateAccStruct(fullName: fullName, phoneNo: phoneNo, password: password, gender: gender, genderPref: genderPref, ethnicity: ethnicity, ethnicPref: ethnicPref, devToken: devToken)
                
                createAcc(createAccStruct)
                
            } else {
                
                var creds = ["phoneNo" : phoneNo, "password" : password]
                
                if let devToken = UserDefaults.standard.string(forKey: "devToken") {
                    creds["devToken"] = devToken
                }

                login(creds)
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
    
    func createAcc(_ params: CreateAccStruct) {
        let url = APIEndpoints.CREATE_ACC
                
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                if let JSON = value as? [String: Any] {
                    
                    if let status = JSON["status"] as? Bool {
                        if(status) {
                            if let client = JSON["result"] as? [String: Any] {
                                handleLoginResponse(true, "", client)
                            } else {
                                handleLoginResponse(false, "Error \(#line)", NSNull())
                            }
                        } else {
                            if let error = JSON["error"] as? String {
                                if(error.elementsEqual("ExistingUserError")) {
                                    handleLoginResponse(false, "A User with phone number already exists. Please sign in or contact support", NSNull())
                                }
                            } else {
                                handleLoginResponse(false, "Error \(#line)", NSNull())
                            }
                        }
                    } else {
                        handleLoginResponse(false, "Error \(#line)", NSNull())
                    }
                } else {
                    handleLoginResponse(false, "Error \(#line)", NSNull())
                }
            case let .failure(error):
                handleLoginResponse(false, "Network Error \(#line)", error)
            }
        }
    }
    
    public func login(_ params: [String: String]) -> Void{
        isLoading = true
        
        let url = APIEndpoints.CLIENT_LOGIN
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
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
                guard let clientId = client["_id"] as? String else {
                    return handleLoginResponse(false, "Error \(#line)", nil)
                }
                
                guard let clientName = client["fullName"] as? String else {
                    return handleLoginResponse(false, "Error \(#line)", nil)
                }
                
                UserDefaults.standard.set(clientId, forKey: "id")
                UserDefaults.standard.set(clientName, forKey: "fullName")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.set(phoneNo, forKey: "phoneNo")
                UserDefaults.standard.set(password, forKey: "password")
                UserDefaults.standard.set("client", forKey: "userType")
                
                if let callIds = client["calls"] as? [String] {
                    
                    if(!callIds.isEmpty) {
                        UserDefaults.standard.set(true, forKey: "hasCalls")
                        
                        getCallInfo(clientId)
                        
                    } else {
                        
                        UserDefaults.standard.set(false, forKey: "hasCalls")
                        
                        self.calls = []
                        
                        isLoggedIn = true
                        
                    }
                    
                }
            } else {
                handleLoginResponse(false, "Error \(#line)", NSNull())
            }
            
        } else {
            loginError = true
            loginErrorText = message
        }
        isLoading = false
    }
    
    func getCallInfo(_ clientId: String?) {
        AF.request(APIEndpoints.GET_CLIENT_CALLS, method: .post, parameters: ["id" : clientId], encoder: JSONParameterEncoder.default).responseJSON { response in
            switch response.result {
            case let .success(value):
                
                guard let dict = value as? [String: Any] else  {
                    return handleGetCallsResponse(false, "Error \(#line)", nil)

                }
                
                guard let status = dict["status"] as? Bool else {
                    return handleGetCallsResponse(false, "Error \(#line)", nil)
                }
                
                if(status) {
                    
                    
                    guard let callDicts = dict["result"] as? [[String:Any]] else {
                        return handleGetCallsResponse(false, "Error \(#line)", nil)
                    }
                    
                    var funcCalls: [[String: String]] = []
                    
                    callDicts.forEach { callDict in
                        
                        guard let callTimeString = callDict["time"] as? String else {
                            return handleGetCallsResponse(false, "Error \(#line)", nil)
                        }
                        
                        guard let callDateString = callDict["date"] as? String else {
                            return handleGetCallsResponse(false, "Error \(#line)", nil)
                        }
                        
                        guard let callIdString = callDict["_id"] as? String else {
                            return handleGetCallsResponse(false, "Error \(#line)", nil)
                        }
                        
                        guard let callCallerDict = callDict["caller"] as? [String: String]  else{
                            return handleGetCallsResponse(false, "Error \(#line)", nil)
                        }
                        
                        guard let callCallerString = callCallerDict["fullName"] else {
                            return handleGetCallsResponse(false, "Error \(#line)", nil)
                        }
                        
                        var hasRatingString = ""
                        
                        if Helpers.isInFuture(callDateString, callTimeString) || callDict["rating"] == nil {
                            hasRatingString = "F"
                        } else {
                            hasRatingString = "T"
                        }
                        var call = ["date" : callDateString , "time" : callTimeString , "callerName" : callCallerString, "id" : callIdString, "hasRating" : hasRatingString]
                        
                        if let hasNotif = callDict["hasNotif"] as? Bool {
                            if hasNotif {
                                if let notifTime = callDict["notifTime"] {
                                    if "\(notifTime)" != "<null>" {
                                        call["notifTime"] = "\(notifTime)"
                                    }
                                }
                            }
                        }
                        
                        funcCalls.append(call)
                    }
                    
                    handleGetCallsResponse(true, nil, funcCalls)
                    
                } else {
                    return handleGetCallsResponse(false, "Error \(#line)", nil)
                }
                
                
            case .failure(_):
                return handleGetCallsResponse(false, "Error \(#line)", nil)
            }
        }
    }
    
    func handleGetCallsResponse(_ status: Bool, _ message: String?, _ result: [[String: String]]?) {
        if(status) {
            calls = result
        }
        
        isLoggedIn = true
        isLoading = false
    }
}

struct Previews_ClientLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ClientLoginView(hasDetailsSaved: false, calls: .constant([]), isLoggedIn: .constant(false))
            .previewDevice(.init(rawValue: "iPhone 13"))
    }
}
