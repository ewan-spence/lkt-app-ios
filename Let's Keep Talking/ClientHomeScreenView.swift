//
//  ClientHomeScreenView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import SwiftUI
import Alamofire

struct ClientHomeScreenView: View {
    @State var userHasCalls: Bool = UserDefaults.standard.bool(forKey: "hasCalls")
    
    @State var callDate: String
    @State var callTime: String
    @State var callCaller: String
    @State var callId: String
    
    @Binding var calls: [[String: String]]?
    
    @State var isAlerting: Bool = false
    @State var alert: Alert?
    
    @State var errorLine: Int?
    
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("Welcome to the Let's Keep Talking App, " + UserDefaults.standard.string(forKey: "fullName")!.split(separator: " ").first!)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding()
                
                Spacer()
                if(userHasCalls && Helpers.isInFuture(callDate, callTime)) {
                    let displayText1 = "Your next call is booked for " + (callTime)
                    let displayText2 = " on " + Helpers.dateReadable(callDate)
                    let displayText3 = " with " + (callCaller)
                    
                    let displayText = displayText1 + displayText2 + displayText3
                    Text(displayText)
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    Button("Cancel Call", action: {isAlerting = true})
                        .alert(isPresented: $isAlerting, content: {
                            alert!
                        })
                        .padding()
                    
                } else {
                    
                    Text("You have no future calls booked, would you like to book one now?")
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    NavigationLink(destination: ClientCallBookerView(userHasCalls: $userHasCalls, callDate: $callDate, callTime: $callTime, callCaller: $callCaller, userCalls: $calls)) {
                        Text("Book Call")
                    }
                    .padding()
                    
                }
                
                Spacer()
                
            }
            
            
            if(isLoading) {
                ProgressView()
            }
        }.onAppear(perform: {
            alert = Alert(title: Text("Confirmation"), message: Text("Are you sure you want to cancel this call?"), primaryButton: .destructive(Text("Cancel Call")) {
                cancelCall()
            }, secondaryButton: .cancel(Text("Back")))
        })
        
    }
    
    func cancelCall() {
        isLoading = true
        
        let url = APIEndpoints.CANCEL_CALL
        
        AF.request(url, method: .post, parameters: ["id" : callId], encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                
                guard let json = value as? [String: Any?] else {
                    return handleCancelResponse(false, #line)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleCancelResponse(false, #line)
                }
                
                return handleCancelResponse(status, #line)
                
            case let .failure(error):
                debugPrint(error)
                
                return handleCancelResponse(false, #line)
            }
        }
        
        
        func handleCancelResponse(_ status: Bool, _ line: Int?) {
            if(status) {
                
                let call = ["id" : callId, "date" : callDate, "time" : callTime, "callerName" : callCaller]
                
                calls?.remove(at: (calls?.firstIndex(of: call))!)
                
                callDate = ""
                callTime = ""
                callId = ""
                callCaller = ""
                
                alert = Alert(title: Text("Call Cancelled"), message: Text("Your call has successfully been cancelled"), dismissButton: .default(Text("Okay")))
                
                
            } else {
                errorLine = line
                
                alert = Alert(title: Text("Error"), message: Text("There was an error cancelling your call - please try again.\nIf this error persists, contact support with error code 3" + String(errorLine!)), dismissButton: .default(Text("Okay")))
                
                isLoading = false
                
                
                isAlerting = true
            }
        }
    }
}
