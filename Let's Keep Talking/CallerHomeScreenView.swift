//
//  CallerHomeScreenView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 13/10/2020.
//

import SwiftUI

struct CallerHomeScreenView: View {
    
    @Binding var calls: [[String: String]]?
    
    @State var todayCalls: [[String: String]]?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to the Let's Keep Talking App")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Divider()
                    .padding()
                
                VStack {
                    
                    Text("Today's Calls")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Divider()
                        .padding()
                    
                    if(todayCalls == nil || todayCalls!.isEmpty) {
                        Spacer()
                        
                        Text("You do not currently have any calls booked today")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Spacer()
                        Spacer()
                        
                    } else {
                        ScrollView {
                            
                            ForEach(todayCalls!, id: \.self) { call in
                                AppointmentRowView(call: call, isClient: false, isOnCallLog: false)
                            }
                        }
                    }
                }.padding()
                
                Spacer()
            }
        }.onAppear(perform: {
            todayCalls = calls?.filter { callIsToday($0) }

        })
    }
    
    func callIsToday(_ call: [String: String]) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let fullDate = call["date"]! + " " + call["time"]!
        let dateAsObj = formatter.date(from: fullDate)
        
        let cal = Calendar(identifier: .gregorian)
        
        return cal.isDateInToday(dateAsObj!)
    }
}

struct CallerFragmentViewTwo_Previews: PreviewProvider {
    static var previews: some View {
        CallerHomeScreenView(calls: .constant([]))
    }
}

