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
    
    @State var callDate: String?
    @State var callTime: String?
    @State var callCaller: String?
    @State var callId: String?
    
    @Binding var calls: [[String: String]]?
    
    @State var isAlerting: Bool = false
    @State var alert: Alert?
    
    @State var errorLine: Int?
    
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    Text("Welcome to the Let's Keep Talking App")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .padding()
                    
                    Spacer()
                    if(userHasCalls && isInFuture(callDate ?? "", callTime ?? "")) {
                        let displayText1 = "Your next call is booked for " + (callTime ?? "")
                        let displayText2 = " on " + dateReadable(callDate ?? "")
                        let displayText3 = " with " + (callCaller ?? "")
                        
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
            }
            
            if(isLoading) {
                ProgressView()
            }
            
        }
        .onAppear(perform: {
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
    }
    
    func handleCancelResponse(_ status: Bool, _ line: Int?) {
        if(status) {
            
            let call = ["id" : callId!, "date" : callDate!, "time" : callTime!, "callerName" : callCaller!]
            
            calls?.remove(at: (calls?.firstIndex(of: call))!)
            
            callDate = ""
            callTime = ""
            callId = ""
            callCaller = ""
            
            alert = Alert(title: Text("Call Cancelled"), message: Text("Your call has successfully been cancelled"), dismissButton: .default(Text("Okay")))
            
            
        } else {
            errorLine = line
            
            alert = Alert(title: Text("Error"), message: Text("There was an error cancelling your call - please try again.\nIf this error persists, contact support with error code 3" + String(errorLine!)), dismissButton: .default(Text("Okay")))
        }
        isLoading = false

 
        isAlerting = true
    }
    
    func dateReadable(_ dateString: String) -> String {
        let monthList: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        
        let dateList = dateString.split(separator: "/")
        
        let dayNo = Int(dateList[0])!
        let monthNo = Int(dateList[1])!
        
        var daySuffix = ""
        
        if([1,21,31].contains(dayNo)) {
            
            daySuffix = "st"
            
        } else if([2,22].contains(dayNo)) {
            
            daySuffix = "nd"
            
        } else if([3,23].contains(dayNo)) {
            
            daySuffix = "rd"
            
        } else {
            daySuffix = "th"
        }
        
        let monthName = monthList[monthNo - 1]
        
        return Helpers.getDayOfWeek(dateString: dateString) + " " + String(dayNo) + String(daySuffix) + " " + String(monthName)
    }
    
    func isInFuture(_ date: String, _ time: String) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let fullDate = date + " " + time
        let dateAsObj = formatter.date(from: fullDate)
        
        let today = Date(timeIntervalSinceNow: 0)
        
        return dateAsObj?.timeIntervalSince(today) ?? 0 > 0
    }
}

struct ClientFragmentViewTwo_Previews: PreviewProvider {
    static var previews: some View {
        ClientHomeScreenView(userHasCalls: true, calls: .constant([]))
    }
}