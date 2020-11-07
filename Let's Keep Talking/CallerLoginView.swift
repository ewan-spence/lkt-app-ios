//
//  CallerLoginView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 19/09/2020.
//

import SwiftUI
import Alamofire

struct CallerLoginView: View {
    @State var hasDetailsSaved: Bool
    
    @State var phoneNo: String = ""
    @State var password: String = ""
    
    @State private var loginError: Bool = false
    @State private var loginErrorText: String = ""
    
    @State private var isLoading: Bool = false
    
    @Binding var isLoggedIn: Bool
    @Binding var calls: [[String: String]]?
    @Binding var availability: [String: [String]]?
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                
                TextField("Phone Number", text: $phoneNo).padding()
                    .keyboardType(.numberPad)
                    .disabled(isLoading)
                SecureField("Password", text: $password).padding()
                    .disabled(isLoading)
                
                
                Button("Sign In", action: onClick).padding()
                    .disabled(phoneNo.isEmpty || password.isEmpty || isLoading)
                    .alert(isPresented: $loginError) {
                        Alert(title: Text("Error"), message: Text(loginErrorText), dismissButton: .default(Text("Got it!")))
                    }
                
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
    
    func onClick() -> Void {
        let creds = LoginStruct(phoneNo: phoneNo, password: password)
        let URL = APIEndpoints.CALLER_LOGIN
        
        isLoading = true
        
        AF.request(URL, method: .post, parameters: creds, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                
                // Try casting the response to a JSON
                if let JSON = value as? [String: Any] {
                    
                    // Try casting the "status" field to a boolean (if this fails, the response is from AWS, not the API)
                    if let status = JSON["status"] as? Bool {
                        
                        if(status) {
                            if let client = JSON["result"] as? [String: Any] {
                                handleLoginResponse(true, nil, client)
                            } else {
                                handleLoginResponse(false, "Error \(#line)", nil)
                            }
                        } else {
                            if let error = JSON["error"] as? String {
                                if(error.elementsEqual("IncorrectPassword")) {
                                    handleLoginResponse(false, "Incorrect Password. Please try again", nil)
                                } else if(error.elementsEqual("NoUser")) {
                                    handleLoginResponse(false, "No user exists with that phone number, please create an account", nil)
                                } else {
                                    handleLoginResponse(false, "Error \(#line)", nil)
                                }
                            } else {
                                handleLoginResponse(false, "Error \(#line)", nil)
                            }
                        }
                    }
                } else {
                    handleLoginResponse(false, "Error \(#line)", nil)
                }
                
                
                
            case let .failure(error):
                handleLoginResponse(false, "Network Error \(#line)", error)
            }
        }
    }
    
    
    func handleLoginResponse(_ status: Bool, _ message: String?, _ result: Any?) -> Void{
        if(status) {
            
            if let caller = result as? [String: Any] {
                guard let callerId = caller["_id"] as? String else {
                    return handleLoginResponse(false, "Error \(#line)", nil)
                }
                
                availability = caller["availability"] as? [String : [String]]
                
                guard let dbCalls = caller["calls"] as? [String] else {
                    return handleLoginResponse(false, "Error \(#line)", nil)
                }
                
                // TODO: Add keychain support
                
                UserDefaults.standard.set(callerId, forKey: "id")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.set(phoneNo, forKey: "phoneNo")
                UserDefaults.standard.set(password, forKey: "password")
                UserDefaults.standard.set("caller", forKey: "userType")
                
                
                if(!dbCalls.isEmpty) {
                    calls = []
                    getCalls(callerId)
                } else {
                    isLoading = false
                    isLoggedIn = true
                }
            }
        } else {
            loginError = true
            loginErrorText = message!
            isLoading = false
        }
    }
    
    func getCalls(_ id: String) -> Void {
        let url = APIEndpoints.GET_CALLER_CALLS
        
        let params = ["id" : id]
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch(response.result) {
            case let .success(value):
                
                guard let json = value as? [String: Any] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                if(status) {
                    guard let array = json["result"] as? [[String: Any]] else {
                        return handleGetCallsResponse(false, #line, nil)
                    }
                    
                    return handleGetCallsResponse(true, nil, array)
                }
                
            case let .failure(error):
                debugPrint(error)
                return handleGetCallsResponse(false, #line, nil)
            }
        }
    }
    
    func handleGetCallsResponse(_ status: Bool, _ lineNo: Int?, _ result: [[String: Any]]?) {
        if(status) {
            
            result!.forEach { call in
                guard let callId = call["_id"] as? String else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let callDate = call["date"] as? String else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let callTime = call["time"] as? String else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let callClient = call["client"] as? [String: String] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let clientName = callClient["fullName"] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let clientNumber = callClient["phoneNo"] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                var newCall = ["id" : callId, "date" : callDate, "time" : callTime, "clientName" : clientName, "clientNo" : clientNumber]
                
                if let callLength = call["length"] as? String {
                    newCall["length"] = callLength
                } 
                
                calls?.append(newCall)
                
            }
            
        } else {
            loginErrorText = "Logged in successfully, but there was a problem getting your account information.\nIf this error persists, please contact support with code " + String(lineNo!)
            loginError = true
        }
        
        isLoggedIn = true
        isLoading = false
    }
    
}

struct CallerLoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        CallerLoginView(hasDetailsSaved: false, isLoggedIn: .constant(false), calls: .constant([]), availability: .constant([:]))
    }
}
