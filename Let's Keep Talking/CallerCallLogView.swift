//
//  CallerCallLogView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 12/10/2020.
//

import SwiftUI

struct CallerCallLogView: View {
    
    @Binding var calls: [[String: String]]?
    
    var body: some View {
        VStack {
            Text("Call Log")
                .font(.title)
                .padding()
            
            Spacer()
            
            ScrollView {
                ForEach((calls ?? []).sorted(by: Helpers.sortCalls), id: \.self) { call in
                    AppointmentRowView(call: call, isClient: false, isOnCallLog: true)
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
