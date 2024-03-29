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
    
    @Binding var isAlerting: Bool
    @Binding var alert: Alert
    
    @State var isConfirming: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("Welcome to the Let's Keep Talking App, " + UserDefaults.standard.string(forKey: "fullName")!.split(separator: " ").first!)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Divider()
                
                VStack {
                    
                    Text("Today's Calls")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Divider()
                    
                    if(todayCalls == nil || todayCalls!.isEmpty) {
                        Spacer()
                        
                        Text("You do not currently have any calls booked today")
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Spacer()
                        
                    } else {
                        
                        ScrollView {
                            ForEach(todayCalls!, id: \.self) { call in
                                AppointmentRowView(call: call, isClient: false, isOnCallLog: false, isAlerting: $isAlerting, alert: $alert, callId: call["id"]!, isLoading: $isLoading, calls: $calls)
                            }
                        }
                        
                    }
                    
                    if(calls != nil) {
                        
                        Divider()
                        
                        Spacer()
                        
                        NavigationLink("Book New Call", destination: CallerCallBookerView(clients: [], calls: $calls))
                        
                        Spacer()
                    }
                    
                }.padding()
                
                Spacer()
            }
            if(isLoading) {
                ProgressView()
            }
            
        }.onAppear(perform: {
            todayCalls = calls?.filter { callIsToday($0) }
            todayCalls?.sort(by: Helpers.callSorter)
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

//struct CallerFragmentViewTwo_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            CallerHomeScreenView(calls: .constant([]))
//                .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
//                .previewDisplayName("iPhone 7")
//            
//            CallerHomeScreenView(calls: .constant([]))
//                .previewDevice(PreviewDevice(rawValue: "iPhone XR"))
//                .previewDisplayName("iPhone XR")
//        }
//    }
//}

