//
//  Helpers.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 28/09/2020.
//

import SwiftUI

struct Helpers: View {
    var body: some View {
        EmptyView()
    }
    
    public static func sortCalls(call1: [String: String], call2: [String: String]) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let call1Date = dateFormatter.date(from: call1["date"]!)!
        let call2Date = dateFormatter.date(from: call2["date"]!)!
        
        if(call1Date < call2Date) {
            return true
        }
        if(call1Date > call2Date) {
            return false
        }
        
        dateFormatter.dateFormat = "HH:mm"
        
        let call1Time = dateFormatter.date(from: call1["time"]!)!
        let call2Time = dateFormatter.date(from: call2["time"]!)!
        
        return call1Time < call2Time
        
    }
    
    public static func getDayOfWeek(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let callDate = dateFormatter.date(from: dateString)!
        
        let cal = Calendar(identifier: .gregorian)
        
        return dateFormatter.shortWeekdaySymbols[cal.component(.weekday, from: callDate) - 1]
    }
    
    public static func dateReadable(_ dateString: String) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_GB")
        
        let monthList = df.monthSymbols!
        
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
    
    public static func isInFuture(_ date: String, _ time: String) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let fullDate = date + " " + time
        let dateAsObj = formatter.date(from: fullDate)
        
        let today = Date(timeIntervalSinceNow: 0)
        
        return dateAsObj?.timeIntervalSince(today) ?? 0 > 0
    }
    
    public static func getDateSuffix(_ dayNo: Int) -> String {
        switch dayNo {
        case 11...13: return "th"
        default:
            switch dayNo % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
}

struct CreateAccStruct: Encodable {
    let fullName: String
    let phoneNo: String
    let password: String
    let gender: String
    let genderPref: String
    let ethnicity: String
    let ethnicPref: Bool
    
    let devToken: String?
}

struct AvailStruct: Encodable {
    let callerSelected: Bool
    let callerName: String
    let clientId: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

struct Helpers_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
