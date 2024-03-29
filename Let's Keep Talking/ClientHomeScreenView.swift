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
    
    @Binding var calls: [[String: String]]?
    
    @Binding var isAlerting: Bool
    @Binding var alert: Alert
    
    @State var errorLine: Int?
    
    @State var chosen: Int = 0
    
    @State var isLoading: Bool = false
    
    func heading() -> String {
        if let name = UserDefaults.standard.string(forKey: "fullName") {
            return "Welcome to the Let's Keep Talking App, " + name.split(separator: " ").first!
        } else {
            return "Welcome to the Let's Keep Talking App"
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text(heading())
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .font(Helpers.brandFont(size: 40))
                    .foregroundColor(Color("text"))
                    .padding()
                
                Spacer()
                
                
                if(userHasCalls) {
                    let latestCall = calls!.last
                    let latestCallDate = latestCall!["date"]!
                    let latestCallTime = latestCall!["time"]!
                    let latestCallCaller = latestCall!["callerName"]!
                    
                    if(Helpers.isInFuture(latestCallDate, latestCallTime)) {
                        
                        let latestCallNotifTime = latestCall?["notifTime"]
                        
                        let displayText1 = "Your next call is booked for " + (latestCallTime)
                        let displayText2 = " on " + Helpers.dateReadable(latestCallDate)
                        let displayText3 = " with " + (latestCallCaller)
                        
                        let displayText = displayText1 + displayText2 + displayText3
                        Text(displayText)
                            .multilineTextAlignment(.center)
                            .padding(30)
                        
                        Button("Cancel Call", action: {
                            alert = Alert(title: Text("Confirmation"), message: Text("Are you sure you want to cancel this call?"), primaryButton: .destructive(Text("Cancel Call")) {
                                cancelCall()
                            }, secondaryButton: .cancel(Text("Back")))
                            
                            isAlerting = true
                        })
                        .disabled(isLoading)
                        .padding()
                        
                        Divider()
                        
                        if let notifTime = latestCallNotifTime {
                            Text("You have a reminder set for \(minutesToReadable(Int(notifTime)!)) before this call")
                                .font(Helpers.brandFont(size: 18))
                                .foregroundColor(Color("text"))
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Remove Reminder", action: {
                                isLoading = true
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                submitToDb(false)
                            })
                            .disabled(isLoading)
                            
                        } else {
                            Text("Please select how long before this call you would like to be reminded (optional)")
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            AlertPicker(chosenNumMinutes: $chosen)
                            
                            Button("Submit Alert", action: submitAlert)
                                .disabled(isLoading)
                        }
                        
                    }
                    
                }
                
                Text("You have no future calls booked, would you like to book one now?")
                    .font(Helpers.brandFont(size: 18))
                    .foregroundColor(Color("text"))
                    .multilineTextAlignment(.center)
                    .padding(30)
                
                NavigationLink(destination: ZStack {
                    Color("background").ignoresSafeArea()
                    ClientCallBookerView(userHasCalls: $userHasCalls, userCalls: $calls)
                }) {
                    Text("Book Call")
                }
                .padding()
                
                Spacer()
                
            }
            
            if(isLoading) {
                ProgressView()
            }
        }
    }
    
    func submitAlert() {
        isLoading = true
        
        let cal = Calendar.current
        
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        df.locale = Locale(identifier: "en_GB")
        
        let latestCall = calls!.last!
        
        let latestCallDate = latestCall["date"]!
        let latestCallTime = latestCall["time"]!
        let latestCallCaller = latestCall["callerName"]!
        
        let callDateObject = df.date(from: "\(latestCallDate) \(latestCallTime)")!
        
        let alertDate = cal.date(byAdding: .minute, value: -chosen, to: callDateObject)!
        let alertDateComponents = cal.dateComponents([.day, .month, .year, .hour, .minute], from: alertDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: alertDateComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        
        content.title = "Call Reminder"
        content.body = "Your call with \(latestCallCaller) is in \(minutesToReadable(chosen)) minutes"
        
        let notifRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(notifRequest, withCompletionHandler: {error in
            
            if let error = error {
                debugPrint(error)
                alert = Alert(title: Text("Error"), message: Text("There was an error setting this reminder."), dismissButton: .default(Text("Okay")))
                
                isAlerting = true
                isLoading = false
                
            } else {
                
                submitToDb(true)
            }
        })
    }
    
    func submitToDb(_ notif: Bool) {
        let url = APIEndpoints.CLIENT_NOTIF
        
        let latestCallId = calls?.last!["id"]
        
        var params = ["_id": latestCallId, "hasNotif": String(notif)]
        
        if notif {
            params["notifTime"] = String(chosen)
        }
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            switch response.result {
            case let .success(value):
                guard let json = value as? [String: Any] else {
                    return handleNotifResponse(false, notif: notif, #line)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleNotifResponse(false, notif: notif, #line)
                }
                
                if status {
                    return handleNotifResponse(true, notif: notif, nil)
                }
            case let .failure(error):
                debugPrint(error)
                
                return handleNotifResponse(false, notif: notif, #line)
            }
        }
    }
    
    func handleNotifResponse(_ status: Bool, notif intended: Bool, _ lineNo: Int?) {
        if(status && intended) {
            alert = Alert(title: Text("Reminder Set"), message: Text("Reminder set for \(minutesToReadable(chosen)) before your call"), dismissButton: .default(Text("Okay")))
            
            var latestCall = calls!.removeLast()
            
            latestCall["notifTime"] = String(chosen)
            
            calls?.append(latestCall)
            
        } else if status {
            alert = Alert(title: Text("Reminder Removed"), message: Text("Your call reminder has been removed"), dismissButton: .default(Text("Okay")))
            
            var latestCall = calls!.removeLast()
            
            latestCall.removeValue(forKey: "notifTime")
            
            calls?.append(latestCall)
            
            chosen = 0
        } else {
            alert = Alert(title: Text("Error"), message: Text("There was an error setting this reminder.\nTry again or contact support with error code 11\(lineNo!)"), dismissButton: .default(Text("Okay")))
        }
        
        isAlerting = true
        isLoading = false
    }
    
    func minutesToReadable(_ minutes: Int) -> String{
        if minutes < 60 {
            return "\(minutes) minutes"
        } else if minutes < 120 {
            return "1 hour and \(minutes-60) minutes"
        } else {
            let hours = Int(floor(Float(minutes)/60.0))
            return "\(hours) hours and \(minutes-60*hours) minutes"
        }
    }
    
    func cancelCall() {
        isLoading = true
        
        let url = APIEndpoints.CANCEL_CALL
        
        let call = calls?.last
        
        AF.request(url, method: .post, parameters: call, encoder: JSONParameterEncoder.default).responseJSON { response in
            
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
            
            let call = calls!.last!
            
            calls?.remove(at: (calls?.firstIndex(of: call))!)
            
            alert = Alert(title: Text("Call Cancelled"), message: Text("Your call has successfully been cancelled"), dismissButton: .default(Text("Okay")))
            
            
        } else {
            errorLine = line
            
            alert = Alert(title: Text("Error"), message: Text("There was an error cancelling your call - please try again.\nIf this error persists, contact support with error code 3" + String(errorLine!)), dismissButton: .default(Text("Okay")))
            
        }
        
        isLoading = false
        isAlerting = true
    }
}

