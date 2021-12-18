//
//  AppointmentListView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 11/09/2021.
//

import Alamofire
import SwiftUI

struct AppointmentListView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var selectedCaller: String
    
    @State var appointments: [[String: String]]
    
    @Binding var isLoading: Bool
    @Binding var loadingText: String
    @Binding var userHasCalls: Bool
    @Binding var userCalls: [[String:String]]?
    @Binding var isAlerting: Bool
    @Binding var alertText: String
    
    var body: some View {
        if appointments.isEmpty && isLoading {
            ProgressView(loadingText)
        }
        List(appointments, id: \.self) { call in
            AppointmentRowBookerView(call: call, isLoading: $isLoading, loadingText: $loadingText, userHasCalls: $userHasCalls, calls: $userCalls)
        }
        .onAppear(perform: {
            getAppointments()
        })
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
            
            appointments.sort(by: Helpers.callSorter)
        } else {
            isAlerting = true
            alertText = message!
            mode.wrappedValue.dismiss()
        }
        
        isLoading = false
        loadingText = ""
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
