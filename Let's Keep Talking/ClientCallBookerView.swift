//
//  ClientCallBookerView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 29/09/2020.
//

import Alamofire
import SwiftUI

struct ClientCallBookerView: View {
    @State var rangeSelected: String = ""
    @State var callerSelected: String = ""
    
    @State var callers: [String] = ["No Preference"]
    
    @State var displayCalls: [[String: String]] = []
    
    @State var callsShown: Bool = false
    
    @State var isAlerting: Bool = false
    @State var alertText: String = ""
    
    @State var isLoading: Bool = false
    @State var loadingText: String = "Loading Callers"
    
    @Binding var userHasCalls: Bool
    
    @Binding var callDate: String?
    @Binding var callTime: String?
    @Binding var callCaller: String?
    
    @Binding var userCalls: [[String: String]]?
    
    var body: some View {
        ZStack {
            VStack {
                
                Text("Book a call").font(.title)
                    .padding()
                Spacer()
                
                HStack {
                    
                    Text("Who?").padding()
                    Spacer()
                    Dropdown(displayText: "Pick a caller", options: $callers, selectedItem: $callerSelected)
                        .disabled(isLoading)
                    
                }
                .overlay(RoundedRectangle(cornerRadius: 15).stroke())
                .padding(.horizontal)
                
                Button("Show Appointments", action: {
                    getCalls()
                    
                })
                .alert(isPresented: $isAlerting) {
                    Alert(title: Text("Error"), message: Text(alertText), dismissButton: .default(Text("Okay")))
                }
                .padding(.top, 30)
                .disabled(callerSelected.isEmpty || isLoading)
                
                if(callsShown && (!displayCalls.isEmpty)) {
                    ScrollView {
                        
                        ForEach(displayCalls, id: \.self) { call in
                            AppointmentRowBookerView(call: call, isLoading: $isLoading, loadingText: $loadingText, userHasCalls: $userHasCalls, nextCallDate: $callDate, nextCallTime: $callTime, nextCallCaller: $callCaller, calls: $userCalls)
                        }
                    }
                }
                Spacer()
            }
            
            if(isLoading) {
                ProgressView(loadingText)
            }
            
        }.onAppear(perform: {
            getCallers()
        })
    }
    
    func getCallers() {
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
    
    func getCalls() {
        isLoading = true
        loadingText = "Loading Appointments"
        
        let url = APIEndpoints.GET_APPOINTMENTS
        
        let parameters = AvailStruct(callerSelected : !(callerSelected.isEmpty || callerSelected.elementsEqual("No Preference")), callerName : callerSelected, clientId : UserDefaults.standard.string(forKey: "id") ?? "")
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                // Check that the response is in JSON Format
                guard let JSON = value as? [String: Any] else {
                    return handleCallResponse(false, "Error \(#line)", nil)
                }
                
                // Try casting the "status" field to a boolean (if this fails, the response is from AWS, not the API)
                guard let status = JSON["status"] as? Bool else {
                    return handleCallResponse(false, "Network Error \(#line)", JSON)
                }
                
                if(status) {
                    
                    guard let result = JSON["result"] as? [String: Any] else {
                        return handleCallResponse(false, "Error \(#line)", JSON)
                    }
                    
                    handleCallResponse(true, nil, result)
                    
                } else {
                    return handleCallResponse(false, "Unable to get Call details. Please try again later", [String: Any]())
                }
                
            case let .failure(error):
                return handleCallResponse(false, error.localizedDescription, [String: Any]())
            }
        }
        
        
    }
    
    func handleCallResponse(_ status: Bool, _ message: String?, _ result: [String: Any]?) {
        
        if(status) {
            
            // Result returned will be a dict of the format {date : [caller : [time] ]}
            // i.e, each date has an associated dict of callers, each of whom has an associated list of times
            
            let dates = result!.keys
            
            displayCalls = []
            
            dates.forEach { date in
                guard let callersAvail = result![date] as? [String: [String]] else {
                    return handleCallResponse(false, "Error \(#line)", [String: Any]())
                }
                
                callersAvail.keys.forEach { name in
                    let callerTimes = (callersAvail[name] ?? [])
                    
                    callerTimes.forEach { time in
                        
                        if(isInFuture(date, time)) {
                            let call = ["date" : date, "callerName": name, "time": time]
                            
                            displayCalls.append(call)
                        }
                    }
                }
            }
            
            displayCalls.sort(by: Helpers.sortCalls)
            
            callsShown = true
            
        } else {
            
        }
        
        isLoading = false
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

//struct ClientCallBookerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClientCallBookerView(userHasCalls: .constant(false))
//    }
//}
