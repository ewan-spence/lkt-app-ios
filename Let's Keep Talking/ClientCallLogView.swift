//
//  ClientCallLogView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import Alamofire
import SwiftUI

struct ClientCallLogView: View {
    @State var isOnPastCalls: Bool = true
    @State var isOnFutureCalls: Bool = false
    
    @State var isLoading: Bool = false
    
    @Binding var isAlerting: Bool
    @Binding var alert: Alert
    
    // Assume call is a dictionary of strings with keys: date, time, callerName, id, hasRating
    @Binding var calls: [[String: String]]?
    @State var selectedCall: [String: String] = [:]
    
    var body: some View {
        
        VStack {
            Text("Call Log")
                .font(Helpers.brandFont(size: 40))
                .foregroundColor(Color("text"))
                .padding()
            
            Spacer()
            
            HStack {
                ZStack {
                    HStack {
                        Spacer()
                        
                        Text("Past Calls")
                            .onTapGesture(perform: {
                                isOnPastCalls = true
                                isOnFutureCalls = false
                            })
                        
                        Spacer()
                    }
                    
                    if(isOnPastCalls) {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("accent"), lineWidth: 2)
                    }
                }.frame(height: 40, alignment: .center)
                
                ZStack {
                    HStack {
                        Spacer()
                        
                        Text("Future Calls")
                            .onTapGesture(perform: {
                                isOnPastCalls = false
                                isOnFutureCalls = true
                            })
                        
                        Spacer()
                    }
                    if(isOnFutureCalls) {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("accent"), lineWidth: 2)
                    }
                }.frame(height: 40, alignment: .center)
            }
            
            ScrollView {
                
                if(isOnPastCalls) {
                    ForEach((calls ?? []).filter({ call in
                        !Helpers.isInFuture(call["date"]!, call["time"]!)
                    }).sorted(by: Helpers.callSorter), id: \.self) { call in
                        AppointmentRowView(call: call, isClient: true, isOnCallLog: true, isAlerting: $isAlerting, alert: $alert, callId: "", isLoading: $isLoading, calls: $calls)
                    }
                }
                
                if(isOnFutureCalls) {
                    ForEach((calls ?? []).filter({call in
                        Helpers.isInFuture(call["date"]!, call["time"]!)
                    }).sorted(by: Helpers.callSorter), id: \.self) { call in
                        AppointmentRowView(call: call, isClient: true, isOnCallLog: true, isAlerting: $isAlerting, alert: $alert, callId: "", isLoading: $isLoading, calls: $calls)
                    }
                }
            }.padding()
            
            Spacer()
        }.padding()
    }
}

