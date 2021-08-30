//
//  ClientCallBookerView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 29/09/2020.
//

import Alamofire
import SwiftUI

struct ClientCallBookerView: View {
    @State var selectedCaller: String = ""
    
    @State var callers: [String] = ["No Preference"]
    
    @State var appointments: [[String: String]] = []
    @State var apptsShown: Bool = false
    
    @State var isAlerting: Bool = false
    @State var alertText: String = ""
    
    @State var isLoading: Bool = false
    @State var loadingText: String = "Loading Callers"
    
    @Binding var userHasCalls: Bool
    
    @Binding var userCalls: [[String: String]]?
    
    var body: some View {
        ZStack {
            VStack {
                
                Text("Book a call").font(.title)
                    .padding()
                Spacer()
                
                Form {
                    Picker("Pick a Caller", selection: $selectedCaller, content: {
                        ForEach(callers, id: \.self) { caller in
                            Text(caller)
                        }
                    })
                }
                
                Spacer()
                
                if(apptsShown && (!appointments.isEmpty)) {
                    List(appointments, id: \.self) { call in
                        AppointmentRowBookerView(call: call, isLoading: $isLoading, loadingText: $loadingText, userHasCalls: $userHasCalls, calls: $userCalls)
                    }
                    
                }
                Spacer()
                
                Button("Show Appointments", action: {
                    getAppointments()
                    
                })
                .alert(isPresented: $isAlerting) {
                    Alert(title: Text("Error"), message: Text(alertText), dismissButton: .default(Text("Okay")))
                }
                .padding(.top, 30)
                .disabled(selectedCaller.isEmpty || isLoading)
            }
            
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
    
    func getAppointments() {
        isLoading = true
        loadingText = "Loading Appointments"
        
        let url = APIEndpoints.GET_APPOINTMENTS
        
        let parameters = AvailStruct(callerSelected : !(selectedCaller.isEmpty || selectedCaller.elementsEqual("No Preference")), callerName : selectedCaller, clientId : UserDefaults.standard.string(forKey: "id") ?? "")
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                // Check that the response is in JSON Format
                guard let JSON = value as? [String: Any] else {
                    return handleGetApptResponse(false, "Error \(#line)", nil)
                }
                
                // Try casting the "status" field to a boolean (if this fails, the response is from AWS, not the API)
                guard let status = JSON["status"] as? Bool else {
                    return handleGetApptResponse(false, "Network Error \(#line)", JSON)
                }
                
                if(status) {
                    
                    guard let result = JSON["result"] as? [String: Any] else {
                        return handleGetApptResponse(false, "Error \(#line)", JSON)
                    }
                    
                    handleGetApptResponse(true, nil, result)
                    
                } else {
                    return handleGetApptResponse(false, "Unable to get Call details. Please try again later", [String: Any]())
                }
                
            case let .failure(error):
                return handleGetApptResponse(false, error.localizedDescription, [String: Any]())
            }
        }
    }
    
    func handleGetApptResponse(_ status: Bool, _ message: String?, _ result: [String: Any]?) {
        
        if(status) {
            
            // Result returned will be a dict of the format {date : [caller : [time] ]}
            // i.e, each date has an associated dict of callers, each of whom has an associated list of times
            
            let dates = result!.keys
            
            // Check that there are some available appointments
            if(dates.count == 0) {
                return handleGetApptResponse(false, "There are no calls available with that caller in the next week", nil)
            }
            
            appointments = []
            
            dates.forEach { date in
                guard let callersAvail = result![date] as? [String: [String]] else {
                    return handleGetApptResponse(false, "Error \(#line)", [String: Any]())
                }
                
                callersAvail.keys.forEach { name in
                    let callerTimes = (callersAvail[name] ?? [])
                    
                    callerTimes.forEach { time in
                        
                        if(isInFuture(date, time)) {
                            let call = ["date" : date, "callerName": name, "time": time]
                            
                            appointments.append(call)
                        }
                    }
                }
            }
            
            appointments.sort(by: Helpers.sortCalls)
            
            apptsShown = true
            
        } else {
            isAlerting = true
            alertText = message!
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
