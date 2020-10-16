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
    
    @Binding var calls: [[String: String]]?
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Welcome to the Let's Keep Talking App")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                if(userHasCalls && isInFuture(callDate ?? "", callTime ?? "")) {
                    let displayText1 = "Your next call is booked for " + (callTime ?? "")
                    let displayText2 = " on the " + dateReadable(callDate ?? "")
                    let displayText3 = " with " + (callCaller ?? "")
                    
                    let displayText = displayText1 + displayText2 + displayText3
                    Text(displayText)
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
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
        
        return String(dayNo) + String(daySuffix) + " " + String(monthName)
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
