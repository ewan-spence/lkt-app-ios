//
//  CallerAvailabilityView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 15/10/2020.
//

import SwiftUI
import Alamofire

struct CallerAvailabilityView: View {    
    @State var isOnWeek1: Bool = true
    
    @State var weekOne: [String : [String : [String : Bool]]] = [:]
    @State var weekTwo: [String : [String : [String : Bool]]] = [:]
    
    @State var isLoading: Bool = false
    
    @State var isAlerting: Bool = false
    @State var alertTitle: String = ""
    @State var alertText: String = ""
    @State var alertButton: String = ""
    
    @State var weekOneZoom: CGFloat = 1
    @State var weekTwoZoom: CGFloat = 1
    
    @Binding var isOnViewTwo: Bool
    @Binding var isOnViewThree: Bool
    
    @Binding var isAlertingInSuper: Bool
    @Binding var superAlertTitle: String
    @Binding var superAlertText: String
    @Binding var superAlertButton: String
    
    var body: some View {
        ZStack {
            VStack {
                
                let weekOneTab = Button("Week 1", action: {
                    isOnWeek1 = true
                })
                let weekTwoTab = Button("Week 2", action: {
                    isOnWeek1 = false
                })
                
                HStack {
                    if(isOnWeek1) {
                        weekOneTab
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke()
                                    .foregroundColor(.blue)
                            )
                            .padding()
                        
                        weekTwoTab
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        weekOneTab
                            .padding()
                            .frame(maxWidth: .infinity)
                        
                        weekTwoTab
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke()
                                    .foregroundColor(.blue)
                            )
                            .padding()
                    }
                }
                
                Spacer()
                
                if(isOnWeek1) {
                    WeekView(week: $weekOne)
                        .padding()
                        .scaleEffect(weekOneZoom)
                        .gesture(MagnificationGesture()
                                    .onChanged( { value in
                                        self.weekOneZoom = value.magnitude
                                    }))
                    
                } else {
                    WeekView(week: $weekTwo)
                        .padding()
                        .scaleEffect(weekTwoZoom)
                        .gesture(MagnificationGesture()
                                    .onChanged( { value in
                                        self.weekTwoZoom = value.magnitude
                                    }))
                }
                
                Spacer()
                
                Button("Submit", action: setAvailability)
            }
            
            if(isLoading) {
                ProgressView()
            }
            
        }
        .alert(isPresented: $isAlerting, content: {
            Alert(title: Text(alertTitle), message: Text(alertText), dismissButton: .default(Text(alertButton)))
        })
        .onAppear(perform: {
            getAvailability()
        })
    }
    
    func getAvailability() -> Void {
        isLoading = true
        
        let url = APIEndpoints.GET_AVAILABILITY
        
        let params = ["id" : UserDefaults.standard.string(forKey: "id") ?? ""]
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch(response.result) {
            
            case let .success(value):
                
                guard let json = value as? [String : Any] else {
                    return handleAvailGetResponse(false, #line, nil)
                }
                
                guard let dbResult = json["result"] as? [String: Any] else {
                    return handleAvailGetResponse(false, #line, nil)
                }
                
                return handleAvailGetResponse(true, nil, dbResult)
                
            case let .failure(error):
                debugPrint(error)
                return handleAvailGetResponse(false, #line, nil)
            }
        }
    }
    
    func handleAvailGetResponse(_ status: Bool, _ line: Int?, _ result: [String : Any]?) {
        if(status) {
            guard let dbAvailability = result!["availability"] as? [String: [String]] else {
                return handleAvailGetResponse(false, #line, nil)
            }
            
            guard let dbCalls = result!["calls"] as? [[String: Any]] else {
                return handleAvailGetResponse(false, #line, nil)
            }
            
            let possTimes = ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"]
            
            var availOne: [String: [String: [String: Bool]]] = [:]
            var availTwo: [String: [String: [String: Bool]]] = [:]
            
            var day = Date()
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_GB")
            formatter.dateFormat = "dd/MM/yyyy"
            
            let midDate = Calendar.current.date(byAdding: .day, value: 7, to: day)!
            
            while day <= midDate {
                var hasCall = false
                
                day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
                
                // Check for each call if the call is one of the dates we're checking
                for call in dbCalls {
                    guard let callDateString = call["date"] as? String else {
                        return handleAvailGetResponse(false, #line, nil)
                    }
                    
                    let callDate = formatter.date(from: callDateString)
                    
                    if(callDate == day) {
                        hasCall = true
                        break
                    }
                }
                
                let newDayString = formatter.string(from: day)
                
                // Check if the database availability has the day we're checking
                if(dbAvailability.keys.contains(newDayString)) {
                    
                    // If it does,
                    var dayAvailability: [String: [String: Bool]] = [:]
                    
                    for time in possTimes {
                        let isAvail = dbAvailability[newDayString]!.contains(time)
                        
                        dayAvailability[time] = [:]
                        
                        dayAvailability[time]!["isAvail"] = isAvail
                        dayAvailability[time]!["hasCall"] = hasCall
                        
                    }
                    
                    availOne[newDayString] = dayAvailability
                } else {
                    availOne[newDayString] = [:]
                    
                    for time in possTimes {
                        availOne[newDayString]![time] = ["hasCall" : false, "isAvail" : false]
                    }
                }
            }
            
            let endDate = Calendar.current.date(byAdding: .day, value: 14, to: day)!
            
            
            while day < endDate {
                day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
                
                var hasCall = false
                
                for call in dbCalls {
                    guard let callDateString = call["date"] as? String else {
                        return handleAvailGetResponse(false, #line, nil)
                    }
                    
                    let callDate = formatter.date(from: callDateString)
                    
                    if(callDate == day) {
                        hasCall = true
                        break
                    }
                }
                
                let newDayString = formatter.string(from: day)
                
                // Check if the database availability has the day we're checking
                if(dbAvailability.keys.contains(newDayString)) {
                    
                    // If it does,
                    var dayAvailability: [String: [String: Bool]] = [:]
                    
                    for time in possTimes {
                        let isAvail = dbAvailability[newDayString]!.contains(time)
                        
                        if(hasCall || dbAvailability[newDayString]!.contains(time)) {
                            dayAvailability[time] = [:]
                            dayAvailability[time]!["isAvail"] = isAvail
                            dayAvailability[time]!["hasCall"] = hasCall
                        }
                    }
                    
                    availTwo[newDayString] = dayAvailability
                } else {
                    availTwo[newDayString] = [:]
                    
                    for time in possTimes {
                        availTwo[newDayString]![time] = ["hasCall" : false, "isAvail" : false]
                    }
                }
            }
            
            weekOne = availOne
            weekTwo = availTwo
            
        } else {
            isAlerting = true
            alertTitle = "Error"
            alertText = "There was an error retrieving your availability details - please reload the app.\nIf this error persists, please contact support with error code 1" + String(line!)
            alertButton = "Okay"
        }
        isLoading = false
        
        return
    }
    
    func setAvailability() -> Void {
        isLoading = true
        
        // Transform weekOne to contain both weeks
        var bothWeeks = weekOne
        
        for (key, value) in weekTwo {
            bothWeeks[key] = value
        }
        
        var availability: [String: [String]] = [:]
        
        for (dayString, timeDict) in bothWeeks {
            
            for (timeString, avail) in timeDict {
                
                if(avail["isAvail"]!) {
                    
                    if availability[dayString] != nil {
                        
                        availability[dayString]!.append(timeString)
                    } else {
                        availability[dayString] = [timeString]
                    }
                }
            }
        }
        
        let callerId = UserDefaults.standard.string(forKey: "id")!
        
        let url = APIEndpoints.SET_AVAILABILITY
        
        AF.request(url, method: .post, parameters: SetAvailStruct(callerId: callerId, availability: availability), encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch (response.result) {
            case let .success(value):
                guard let json = value as? [String: Any] else {
                    return handleSetAvailResponse(false, #line)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleSetAvailResponse(false, #line)
                }
                
                if (status) {
                    return handleSetAvailResponse(true, nil)
                } else {
                    return handleSetAvailResponse(false, #line)
                }
            case let .failure(error):
                debugPrint(error)
                return handleSetAvailResponse(false, #line)
            }
        }
        
    }
    
    func handleSetAvailResponse(_ status: Bool, _ lineNo: Int?) {
        
        
        if(status) {
            isAlertingInSuper = true
            superAlertTitle = "Availability Set"
            superAlertText = "Your availability has been set"
            superAlertButton = "Okay"
            
            isOnViewTwo = true
            isOnViewThree = false
        } else {
            isAlerting = true
            alertButton = "Okay"
            alertTitle = "Error"
            alertText = "There was an error setting your availability - please reload the app or try again later.\nIf this problem persists, please contact support with code 2" + String(lineNo!)
        }
        
        isLoading = false
    }
}

struct SetAvailStruct: Encodable {
    let callerId: String
    let availability: [String: [String]]
}

//struct CallerAvailabilityView_Previews: PreviewProvider {
//    static var previews: some View {
//        CallerAvailabilityView()
//    }
//}
