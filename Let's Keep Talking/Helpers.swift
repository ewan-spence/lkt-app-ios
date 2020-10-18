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
        
        return dateFormatter.weekdaySymbols[cal.component(.weekday, from: callDate) - 1]
    }
}

struct LoginStruct: Encodable {
    let phoneNo: String
    let password: String
}

struct CreateAccStruct: Encodable {
    let fullName: String
    let phoneNo: String
    let password: String
    let gender: String
    let genderPref: String
    let ethnicity: String
    let ethnicPref: Bool
}

struct AvailStruct: Encodable {
    let callerSelected: Bool
    let callerName: String
    let clientId: String
}

struct Dropdown: View {
    @State var expand = false
    @State var displayText: String
    
    @Binding var options: [String]
    
    @Binding var selectedItem: String
    
    var body: some View {
        
        VStack{
            HStack {
                Text(displayText)
                    .foregroundColor(.blue)
                
                
                if(expand) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.blue)
                }
                
            }
            .onTapGesture(perform: {
                expand.toggle()
            })
            .padding()
            
            if(expand) {
                
                ForEach(options, id: \.self) { value in
                    Text(value)
                        .onTapGesture(perform: {
                            displayText = value
                            selectedItem = value
                            expand = false
                        })
                        .padding(.bottom)
                }
                
            }
        }
        
    }
}


enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
