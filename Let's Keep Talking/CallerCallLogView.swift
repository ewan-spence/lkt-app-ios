//
//  CallerCallLogView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 12/10/2020.
//

import SwiftUI

struct CallerCallLogView: View {
    @State var isOnAllCalls: Bool = true
    @State var isOnFutureCalls: Bool = false
    
    @Binding var calls: [[String: String]]?
    
    var body: some View {
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
                        AppointmentRowView(call: call, isClient: false, isOnCallLog: true)
                    }
                }
                if(isOnFutureCalls) {
                    ForEach((calls ?? []).filter({ call in
                        Helpers.isInFuture(call["date"]!, call["time"]!)
                    }).sorted(by: Helpers.sortCalls).reversed(), id: \.self) { call in
                        AppointmentRowView(call: call, isClient: false, isOnCallLog: true)
                    }
                }
            }
            
        }
        
    }
}

struct CallerFragmentViewOne_Previews: PreviewProvider {
    static var previews: some View {
        CallerCallLogView(calls: .constant([]))
    }
}
