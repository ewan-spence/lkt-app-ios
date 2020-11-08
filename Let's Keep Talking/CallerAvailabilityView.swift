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
    
    @State var weekOneZoom: CGFloat = 1
    @State var weekTwoZoom: CGFloat = 1
    
    @Binding var isOnViewTwo: Bool
    @Binding var isOnViewThree: Bool
    
    @Binding var isAlerting: Bool
    @Binding var alert: Alert
    
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
            
            let dbCallsInFuture = dbCalls.filter({call in
                return Helpers.isInFuture(call["date"] as! String, call["time"] as! String)
            })
            
            let day = Date()
            
            let midDate = Calendar.current.date(byAdding: .day, value: 7, to: day)!
            
            let endDate = Calendar.current.date(byAdding: .day, value: 14, to: day)!
            
            guard let availOne = getWeekAvailability(day, midDate, dbAvailability, dbCallsInFuture) else {
                return handleAvailGetResponse(false, #line, nil)
            }
            guard let availTwo = getWeekAvailability(midDate, endDate, dbAvailability, dbCallsInFuture) else {
                return handleAvailGetResponse(false, #line, nil)
            }
            
            weekOne = availOne
            weekTwo = availTwo
            
        } else {
            alert = Alert(title: Text("Error"), message: Text("There was an error retrieving your availability details - please reload the app.\nIf this error persists, please contact support with error code 1" + String(line!)), dismissButton: .default(Text("Okay")))
            isAlerting = true
        }
        isLoading = false
        
        return
    }
    
    func getWeekAvailability(_ date1: Date, _ date2: Date, _ dbAvailability: [String : [String]], _ dbCalls: [[String: Any]]) -> [String: [String: [String: Bool]]]? {
        var avail: [String: [String: [String: Bool]]] = [:]
        
        let possTimes = ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let dateAndTimeFormatter = DateFormatter()
        dateAndTimeFormatter.locale = Locale(identifier: "en_GB")
        dateAndTimeFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_GB")
        timeFormatter.dateFormat = "HH:mm"
        
        let cal = Calendar(identifier: .gregorian)
        
        var date1Var = Calendar.current.date(byAdding: .day, value: 1, to: date1)!
        
        while date1Var <= date2 {            
            var dayAvail: [String: [String: Bool]] = [:]
            
            let dateString = dateFormatter.string(from: date1Var)
            
            for (day, timeList) in dbAvailability {
                if(day == dateString) {
                    for time in possTimes {
                        dayAvail[time] = ["isAvail" : timeList.contains(time)]
                    }
                    
                    break
                }
            }
            
            if(dayAvail == [:]) {
                for time in possTimes {
                    dayAvail[time] = ["isAvail" : false]
                }
            }
            
            if(dbCalls.isEmpty) {
                for timeString in possTimes {
                    
                    if(!(dayAvail[timeString]?.keys.contains("hasCall"))!) {
                        
                        dayAvail[timeString]!["hasCall"] = false
                    }
                }
            }
            else {
                for call in dbCalls {
                    
                    for timeString in possTimes {
                        
                        if(!(dayAvail[timeString]!["hasCall"] ?? false)) {
                            
                            guard let callDateString = call["date"] as? String else {
                                handleAvailGetResponse(false, #line, nil)
                                return nil
                            }
                            
                            guard let callTimeString = call["time"] as? String else {
                                handleAvailGetResponse(false, #line, nil)
                                return nil
                            }
                            
                            let callAsDateObj = dateAndTimeFormatter.date(from: callDateString + " " + callTimeString)!
                            
                            dayAvail[timeString]!["hasCall"] = (cal.isDate(callAsDateObj, inSameDayAs: date1Var)) && (callTimeString == timeString)
                        }
                    }
                }
            }
            avail[dateString] = dayAvail
            
            date1Var = Calendar.current.date(byAdding: .day, value: 1, to: date1Var)!
        }
        return avail
        
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
                    return handleAvailSetResponse(false, #line)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleAvailSetResponse(false, #line)
                }
                
                if (status) {
                    return handleAvailSetResponse(true, nil)
                } else {
                    return handleAvailSetResponse(false, #line)
                }
            case let .failure(error):
                debugPrint(error)
                return handleAvailSetResponse(false, #line)
            }
        }
        
    }
    
    func handleAvailSetResponse(_ status: Bool, _ lineNo: Int?) {
        if(status) {
            alert = Alert(title: Text("Availability Set"), message: Text("Your availability has been set"), dismissButton: .default(Text("Okay")))
            
            isOnViewTwo = true
            isOnViewThree = false
        } else {
            alert = Alert(title: Text("Error"), message: Text("There was an error setting your availability - please reload the app or try again later.\nIf this problem persists, please contact support with code 2" + String(lineNo!)), dismissButton: .default(Text("Okay")))
            
            isOnViewTwo = true
            isOnViewThree = false
        }
        isAlerting = true
        
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
