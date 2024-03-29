//
//  ClientCallBookerView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 29/09/2020.
//

import Alamofire
import SwiftUI

struct ClientCallBookerView: View {    
    @State var callers: [String] = ["No Preference"]
    
    @State var isAlerting: Bool = false
    @State var alertText: String = ""
    
    @State var isLoading: Bool = false
    @State var loadingText: String = "Loading Callers"
    
    @Binding var userHasCalls: Bool
    
    @Binding var userCalls: [[String: String]]?
    
    var body: some View {
        VStack {
            
            Text("Book a call").font(.title)
                .padding()
            
            List(callers, id: \.self) { caller in
                NavigationLink(caller, destination:
                                ZStack {
                    Color("background").ignoresSafeArea()
                    AppointmentListView(selectedCaller: caller, appointments: [], isLoading: $isLoading, loadingText: $loadingText, userHasCalls: $userHasCalls, userCalls: $userCalls, isAlerting: $isAlerting, alertText: $alertText)
                        .alert(isPresented: $isAlerting) {
                            Alert(title: Text("No Appointments"), message: Text(alertText), dismissButton: .default(Text("OK")))
                        }
                }
                )}
            .background(Color("background").opacity(0))
            if(isLoading) {
                ProgressView(loadingText)
            }
        }.onAppear(perform: {
            getCallers()
        })
    }
    
    func getCallers() {
        if(callers.count > 1) {
            return
        }
        
        isLoading = true
        loadingText = "Loading Callers"
        
        let url = APIEndpoints.GET_CALLERS
        
        let clientId = UserDefaults.standard.string(forKey: "id");
        let parameters = ["clientId" : clientId]
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseJSON {response in
            
            switch response.result {
            case let .success(value):
                
                // Check that the response is in JSON Format
                guard let JSON = value as? [String: Any] else {
                    handleCallerResponse(false, "Error \(#line)", NSNull())
                    return
                }
                
                // Check that the body is a string
                guard let body = JSON["body"] as? String else {
                    handleCallerResponse(false, "Error \(#line)", NSNull())
                    return
                }
                
                let data: Data? = body.data(using: .utf8)
                
                // Check that the body is serializable
                guard let jsonBody = (try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])) as? [String:Any] else {
                    
                    handleCallerResponse(false, "Error \(#line)", NSNull())
                    return
                }
                
                // Try casting the "status" field to a boolean (if this fails, the response is from AWS, not the API)
                guard let status = jsonBody["status"] as? Bool else {
                    handleCallerResponse(false, "Network Error \(#line)", NSNull())
                    return
                }
                
                if(status) {
                    
                    if let result = jsonBody["result"] as? [Any] {
                        handleCallerResponse(true, "", result)
                    } else {
                        handleCallerResponse(false, "Error \(#line)", NSNull())
                    }
                } else {
                    handleCallerResponse(false, "Unable to get Caller details. Please try again later", NSNull())
                }
                
            case let .failure(error):
                if let message = error.errorDescription {
                    handleCallerResponse(false, message, NSNull())
                } else {
                    handleCallerResponse(false, "Error \(#line)", NSNull())
                }
            }
            
        }
    }
    
    func handleCallerResponse(_ status: Bool, _ message: String, _ result: Any?) -> Void{
        if(status) {
            guard let resultList = result as? [Any] else {
                handleCallerResponse(false, "Error \(#line)", NSNull())
                return
            }
            
            for caller in resultList {
                guard let callerJson = caller as? [String: Any] else {
                    continue
                }
                
                guard let name = callerJson["fullName"] as? String else {
                    continue
                }
                
                self.callers.append(name)
            }
        }
        isLoading = false
        
    }
}

struct Previews_ClientCallBookerView_Previews: PreviewProvider {
    static var previews: some View {
        ClientCallBookerView(callers: [], isAlerting: false, alertText: "", isLoading: false, loadingText: "", userHasCalls: .constant(false), userCalls: .constant([]))
    }
}
