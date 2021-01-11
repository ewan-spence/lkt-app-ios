//
//  AppointmentRowBookerView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 06/10/2020.
//

import SwiftUI
import Alamofire

struct AppointmentRowBookerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var call: [String: String]
    
    @State var show: Bool = true

    @State var isAlerting: Bool = false
    @State var alertTitle: String = ""
    @State var alertText: String = ""
    @State var alertButton: String = ""
        
    @Binding var isLoading: Bool
    @Binding var loadingText: String
    @Binding var userHasCalls: Bool
        
    @Binding var calls: [[String : String]]?
        
    var body: some View {
        if(show) {
            HStack{
                VStack {
                    Text(Helpers.getDayOfWeek(dateString: call["date"]!))
                    Text(call["date"] ?? "")
                    Text(call["time"] ?? "")
                }.padding()
                
                Spacer()
                
                Button("Book Call", action: bookCall).alert(isPresented: $isAlerting) {
                    Alert(title: Text(alertTitle), message: Text(alertText), dismissButton: .default(Text(alertButton)))
                }.foregroundColor(.blue)
                .disabled(isLoading)
                
                Spacer()
                
                Text(call["callerName"] ?? "").padding(.trailing)
                
                
            }
        }
    }
    
    func bookCall() -> Void {
        isLoading = true
        loadingText = "Booking Call"
        
        let clientId = UserDefaults.standard.string(forKey: "id")
        let params = ["callerName" : call["callerName"], "clientId": clientId, "date": call["date"], "time": call["time"]]
        let url = APIEndpoints.CLIENT_BOOK_CALL
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                
                guard let dict = value as? [String: Any] else {
                    return handleBookResponse(false, "Error \(#line)", nil)
                }
                
                guard let status = dict["status"] as? Bool else {
                    return handleBookResponse(false, "Error \(#line)", nil)
                }
                
                if(status) {
                    
                    guard let result = dict["result"] as? [String: Any] else {
                        return handleBookResponse(false, "Error \(#line)", nil)
                    }
                    
                    return handleBookResponse(true, "", result)
                } else {
                    
                    guard let error = dict["error"] as? String else {
                        return handleBookResponse(false, "Error \(#line)", nil)
                    }
                    
                    if(error.elementsEqual("AvailabilityError")) {
                        
                        return handleBookResponse(false, "Sorry, that appointment has been taken, please try another", nil)
                    }
                    
                }
                
                break
            case let .failure(error):
                
                guard let desc = error.errorDescription else {
                    return handleBookResponse(false, "Error \(#line)", nil)
                }
                
                return handleBookResponse(false, "Error: " + desc, nil)
                
            }
        }
    }
    
    func handleBookResponse(_ status: Bool, _ message: String, _ result: [String: Any]?) {
        if(status) {
            guard let json = result else {
                return handleBookResponse(false, "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code \(#line)", nil)
            }
            
            guard let call = json["call"] as? [String: Any] else {
                return handleBookResponse(false, "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code \(#line)", nil)
            }
            
            guard let callId = call["_id"] as? String else {
                return handleBookResponse(false, "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code \(#line)", nil)
            }
            
            guard let callDate = call["date"] as? String else {
                return handleBookResponse(false, "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code \(#line)", nil)
            }
            
            guard let callTime = call["time"] as? String else {
                return handleBookResponse(false, "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code \(#line)", nil)
            }
            
            guard let caller = call["caller"] as? [String: String] else {
                return handleBookResponse(false, "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code \(#line)", nil)
            }
            
            guard let callerName = caller["fullName"] else {
                return handleBookResponse(false, "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code \(#line)", nil)
            }
            
            alertTitle = "Call Booked!"
            alertText = "Your call has been booked on " + callDate
            alertText = alertText + " at " + callTime + " with " + callerName
            alertButton = "Great!"
            
            
            UserDefaults.standard.set(true, forKey: "hasCalls")
            UserDefaults.standard.set(callId, forKey: "nextCall")
            UserDefaults.standard.synchronize()
            userHasCalls = true
            
            calls?.append(["date" : callDate, "time" : callTime, "callerName" : callerName, "id" : callId, "hasRating" : "F"])
            
            self.presentationMode.wrappedValue.dismiss()
            
        } else {
            alertTitle = "Error"
            alertText = message
            alertButton = "Okay"
        }
        
        isLoading = false
        isAlerting = true
    }
}
