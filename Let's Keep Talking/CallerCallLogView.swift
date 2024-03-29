//
//  CallerCallLogView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 12/10/2020.
//

import SwiftUI
import Alamofire

struct CallerCallLogView: View {
    @State var isOnPastCalls: Bool = true
    @State var isOnFutureCalls: Bool = false
    
    @State var isLoading: Bool = false
    
    @Binding var isAlerting: Bool
    
    @Binding var callId: String
    
    @Binding var alert: Alert
    
    @Binding var calls: [[String: String]]?
    
    @State var selectedCall: [String: String] = [:]
    
    var body: some View {
        ZStack {
            VStack {
                Text("Call Log")
                    .font(.title)
                    .padding()
                
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
                                .stroke(Color.green, lineWidth: 5)
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
                                .stroke(Color.green, lineWidth: 5)
                        }
                    }.frame(height: 40, alignment: .center)
                }
                
                ScrollView {
                    if(isOnPastCalls) {
                        ForEach((calls ?? []).filter({ call in
                            !Helpers.isInFuture(call["date"]!, call["time"]!)
                        }).sorted(by: Helpers.callSorter), id: \.self) { call in
                            AppointmentRowView(call: call, isClient: false, isOnCallLog: true, isAlerting: $isAlerting, alert: $alert, callId: callId, isLoading: $isLoading, calls: $calls)
                        }
                    }
                    if(isOnFutureCalls) {
                        ForEach((calls ?? []).filter({ call in
                            Helpers.isInFuture(call["date"]!, call["time"]!)
                        }).sorted(by: Helpers.callSorter), id: \.self) { call in
                            AppointmentRowView(call: call, isClient: false, isOnCallLog: true, isAlerting: $isAlerting, alert: $alert, callId: callId, isLoading: $isLoading, calls: $calls)
                        }
                    }
                }
            }
            if(isLoading) {
                ProgressView()
            }
        }
        
        
    }
}

//struct CallerFragmentViewOne_Previews: PreviewProvider {
//    static var previews: some View {
//        CallerCallLogView(calls: .constant([]))
//    }
//}
