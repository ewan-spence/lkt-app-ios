//
//  ClientCallLogView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import Alamofire
import SwiftUI

struct ClientCallLogView: View {
    @State var isOnAllCalls: Bool = true
    @State var isOnFutureCalls: Bool = false
    
    @State var isLoading: Bool = false
    
    @State var isAlerting: Bool = false
    @State var alert: Alert = Alert(title: Text("Unknown Error"))
            
    // Assume call is a dictionary of strings with keys: date, time, callerName, id
    @Binding var calls: [[String: String]]?
    @State var selectedCall: [String: String] = [:]
    
    var body: some View {
        NavigationView {
            ZStack {
                
                VStack {
                    Text("Call Log")
                        .font(.title)
                        .padding()
                    
                    Spacer()
                    
                    HStack {
                        ZStack {
                            HStack {
                                Spacer()
                                
                                Text("All Calls")
                                    .onTapGesture(perform: {
                                        isOnAllCalls = true
                                        isOnFutureCalls = false
                                    })
                                
                                Spacer()
                            }
                            
                            if(isOnAllCalls) {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.green, lineWidth: 5)
                            }
                        }.frame(height: 40, alignment: .center)
                        
                        ZStack {
                            HStack {
                                Spacer()
                                
                                Text("Future Calls")
                                    .onTapGesture(perform: {
                                        isOnAllCalls = false
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
                        
                        if(isOnAllCalls) {
                            ForEach((calls ?? []).sorted(by: Helpers.sortCalls), id: \.self) { call in
                                AppointmentRowView(call: call, isClient: true, isOnCallLog: true, isAlerting: $isAlerting, alert: $alert, isAddingCallLength: .constant(false), callLength: .constant(""), callId: .constant(""), isLoading: $isLoading, calls: $calls)
                                    .alert(isPresented: $isAlerting, content: {
                                        alert
                                    })
                            }
                        }
                        
                        if(isOnFutureCalls) {
                            ForEach((calls ?? []).filter({call in
                                Helpers.isInFuture(call["date"]!, call["time"]!)
                            }).sorted(by: Helpers.sortCalls), id: \.self) { call in
                                AppointmentRowView(call: call, isClient: true, isOnCallLog: true, isAlerting: $isAlerting, alert: $alert, isAddingCallLength: .constant(false), callLength: .constant(""), callId: .constant(""), isLoading: $isLoading, calls: $calls)
                                    .alert(isPresented: $isAlerting, content: {
                                        alert
                                    })
                                
                            }
                        }
                    }.padding()
                    
                    Spacer()
                }
            }
        }
    }
}
//
//struct ClientFragmentViewOne_Previews: PreviewProvider {
//    static var previews: some View {
//        ClientCallLogView(calls: .constant([["date" : "10/10/2020", "time" : "14:00", "callerName" : "John Doe", "id" : ""]]))
//    }
//}
