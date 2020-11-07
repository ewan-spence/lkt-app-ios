//
//  CallerCallBookerView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 29/10/2020.
//

import Alamofire
import SwiftUI

struct CallerCallBookerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var cal: Calendar = Calendar.current
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    @State var isLoading: Bool = false
    
    @State var isAlerting: Bool = false
    @State var alertTitle: String = ""
    @State var alertText: String = ""
    
    @State var alert: Alert = Alert(title: Text(""))
    
    @State var clients: [String] = []
    @State var selectedClient: String = ""
    
    @State var months: [String] = []
    @State var selectedMonth: String = ""
    
    @State var dates: [String: [String]] = [:]
    @State var possibleDates: [String] = []
    @State var selectedDate: String = ""
    
    @State var times: [String: [String]] = [:]
    @State var possibleTimes: [String] = []
    @State var selectedTime: String = ""
    
    @Binding var calls: [[String: String]]?
    
    var body: some View {
        ZStack {
            VStack {
                Text("Book Call")
                    .font(.largeTitle)
                
                Form {
                    Section {
                        Picker("Select a Client", selection: $selectedClient) {
                            ForEach(clients, id: \.self) { client in
                                Text(client)
                            }
                        }.padding()
                        
                        Picker("Select a Month", selection: $selectedMonth) {
                            ForEach(months, id: \.self) { month in
                                Text(month)
                            }
                        }.padding()
                        
                        Picker("Select a Date", selection: $selectedDate) {
                            ForEach(possibleDates, id: \.self) { date in
                                Text(date)
                            }
                        }
                        .padding()
                        .disabled(selectedMonth.isEmpty)
                        
                        Picker("Select a Time", selection: $selectedTime) {
                            ForEach(possibleTimes, id: \.self) { time in
                                Text(time)
                            }
                        }
                        .padding()
                        .disabled(selectedDate.isEmpty)
                    }
                }
                
                Button("Book Call", action: {
                    alert = Alert(title: Text("Confirm Call Booking"), message: Text("You would like to book a call for " + selectedTime + " on " + selectedDate + " " + selectedMonth + " with " + selectedClient), primaryButton: .default(Text("Yes"), action: bookCall), secondaryButton: .cancel())
                    
                    isAlerting = true
                })
                .alert(isPresented: $isAlerting, content: {
                    alert
                })
                
                
                .disabled(selectedClient.isEmpty || selectedMonth.isEmpty || selectedDate.isEmpty || selectedTime.isEmpty)
                .padding()
                
            }.onAppear(perform: getFormOptions)
            .onChange(of: selectedMonth, perform: { month in
                possibleDates = dates[month]!
                selectedDate = ""
            })
            .onChange(of: selectedDate, perform: { date in
                let fullDate = date + " " + selectedMonth
                
                possibleTimes = times[fullDate] ?? []
                selectedTime = ""
            })
            
            
            if(isLoading) {
                ProgressView()
            }
        }
    }
    
    func getFormOptions() {
        isLoading = true
        let today = Date(timeIntervalSinceNow: 0)
        
        startDate = cal.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        endDate = cal.date(byAdding: .month, value: 1, to: startDate)!
        
        getClientsNames()
        getPossibleMonths()
        getAllDates()
        getAllTimes()
        isLoading = false
    }
    
    func getClientsNames() {
        isLoading = true
        guard let calls = calls else {
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        for call in calls {
            clients.append(call["clientName"]!)
        }
        
        clients = Array(Set(clients))
        isLoading = false
    }
    
    func getPossibleMonths() {
        isLoading = true
        let monthOneNum = cal.component(.month, from: startDate)
        let monthOne = cal.monthSymbols[monthOneNum - 1]
        dates[monthOne] = []
        
        let monthTwoNum = cal.component(.month, from: endDate)
        let monthTwo = cal.monthSymbols[monthTwoNum - 1]
        dates[monthTwo] = []
        
        months = [monthOne, monthTwo]
    }
    
    func getAllDates() {
        isLoading = true
        cal.enumerateDates(startingAfter: startDate, matching: DateComponents(hour: 12, minute: 0, second: 0), matchingPolicy: .nextTime) { date, strict, stop in
            if let date = date {
                
                let month = cal.monthSymbols[cal.component(.month, from: date) - 1]
                
                let day = cal.component(.day, from: date)
                
                let suffix = Helpers.getDateSuffix(day)
                
                let formattedDate : String = cal.weekdaySymbols[cal.component(.weekday, from: date) - 1] + " " + String(cal.component(.day, from: date)) + suffix
                
                dates[month]?.append(formattedDate)
                
                if cal.isDate(date, inSameDayAs: endDate) {
                    stop = true
                }
            }
        }
        isLoading = false
    }
    
    func getAllTimes() {
        isLoading = true
        let fullTimeList = ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"]
        
        for month in months {
            for date in dates[month]! {
                let fullDate = date + " " + month
                
                times[fullDate] = fullTimeList
            }
        }
        
        for call in calls! {
            let callDateString = call["date"]!
            
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_GB")
            df.dateFormat = "dd/MM/yyyy"
            
            let callDate = df.date(from: callDateString)!
            
            let callWeekDay = cal.weekdaySymbols[cal.component(.weekday, from: callDate) - 1]
            let callDay = cal.component(.day, from: callDate)
            let callMonth = cal.monthSymbols[cal.component(.month, from: callDate) - 1]
            
            let fullCallDateString = callWeekDay + " " + String(callDay) + Helpers.getDateSuffix(callDay) + " " + callMonth
            
            let callTime = call["time"]!
            
            times[fullCallDateString]?.remove(at: (times[fullCallDateString]?.firstIndex(of: callTime))!)
        }
        isLoading = false
    }
    
    func readableToDate(_ date: String, _ month: String) -> String{
        // date is in form (e.g) Friday 6th, Monday 10th, etc.
        let dateAsList = date.split(separator: " ")
        
        var dateNum: String = String(dateAsList[1])
        
        dateNum.removeLast()
        dateNum.removeLast()
        
        if(dateNum.count == 1) {
            dateNum = "0" + dateNum
        }
        
        
        let monthNum: Int = cal.monthSymbols.firstIndex(of: month)! + 1
        
        var monthString = String(monthNum)
        
        if(monthString.count == 1) {
            monthString = "0" + monthString
        }
        
        var year = ""
        
        if(months.contains("December") && selectedMonth == "January") {
            year = String(cal.component(.year, from: cal.date(byAdding: .year, value: 1, to: Date(timeIntervalSinceNow: 0))!))
        } else {
            year = String(cal.component(.year, from: Date(timeIntervalSinceNow: 0)))
        }
        
        return dateNum + "/" + monthString + "/" + year
        
    }
    
    func bookCall() {
        isLoading = true
        let url = APIEndpoints.CALLER_BOOK_CALL
        
        let callerId = UserDefaults.standard.string(forKey: "id")
        
        let params = ["clientName" : selectedClient, "callerId": callerId, "date":  readableToDate(selectedDate, selectedMonth), "time": selectedTime]
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                debugPrint(value)
                
                guard let resultJson = value as? [String: Any] else {
                    return handleBookResponse(false, #line, nil)
                }
                
                guard let status = resultJson["status"] as? Bool else {
                    return handleBookResponse(false, #line, nil)
                }
                
                if(status) {
                    
                    guard let bookResult = resultJson["result"] as? [String: Any] else {
                        return handleBookResponse(false, #line, nil)
                    }
                    
                    return handleBookResponse(true, nil, bookResult)
                    
                }
                
                break
            case let .failure(error):
                debugPrint(error)
                return handleBookResponse(false, #line, nil)
            }
            
        }
    }
    
    func handleBookResponse(_ status: Bool, _ lineNo: Int?, _ result: [String: Any]?) {
        if(status) {
            guard let json = result else {
                alertText = "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code 4\(#line)"
                return handleBookResponse(false, nil, nil)
            }
            
            guard let call = json["call"] as? [String: Any] else {
                alertText = "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code 4\(#line)"
                return handleBookResponse(false, nil, nil)
            }
            
            guard let callId = call["_id"] as? String else {
                alertText = "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code 4\(#line)"
                return handleBookResponse(false, nil, nil)
            }
            
            guard let callDate = call["date"] as? String else {
                alertText = "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code 4\(#line)"
                return handleBookResponse(false, nil, nil)
            }
            
            guard let callTime = call["time"] as? String else {
                alertText = "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code 4\(#line)"
                return handleBookResponse(false, nil, nil)
            }
            
            guard let client = call["client"] as? [String: String] else {
                alertText = "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code 4\(#line)"
                return handleBookResponse(false, nil, nil)
            }
            
            guard let clientName = client["fullName"] else {
                alertText = "Call booked - Error retrieving call details. Please reload the app.\nIf the error persists, contact support with code 4\(#line)"
                return handleBookResponse(false, nil, nil)
            }
            
            alertTitle = "Call Booked!"
            alertText = "Your call has been booked on " + callDate
            alertText = alertText + " at " + callTime + " with " + clientName
            
            let newCall = ["date": callDate, "time": callTime, "clientName": clientName, "id": callId]
            
            calls?.append(newCall)
        } else {
            alertTitle = "Error"

            if let lineNo = lineNo {
                alertText = "There has been an error booking this call.\nIf the error persists, contact support with code 4" + String(lineNo)
            }
        }
        alert = Alert(title: Text("Error"), message: Text(alertText), dismissButton: .default(Text("Okay")))
        
        isAlerting = true
        
        isLoading = false
    }
}

struct CallerCallBookerView_Previews: PreviewProvider {
    static var previews: some View {
        CallerCallBookerView(clients: ["John Doe"], calls: .constant([]))
    }
}
