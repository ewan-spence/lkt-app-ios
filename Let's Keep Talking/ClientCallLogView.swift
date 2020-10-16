//
//  ClientCallLogView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import SwiftUI

struct ClientCallLogView: View {
    
    // Assume call is a dictionary of strings with keys: date, time, callerName, id
    @Binding var calls: [[String: String]]?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Call Log")
                    .font(.title)
                    .padding()
                
                Spacer()
            
                ScrollView {
                    ForEach(calls ?? [], id: \.self) { call in                        
                        AppointmentRowView(call: call, isClient: true, isOnCallLog: true)
                    }
                }.padding()
                
                Spacer()
            }
        }
    }
}

struct ClientFragmentViewOne_Previews: PreviewProvider {
    static var previews: some View {
        ClientCallLogView(calls: .constant([["date" : "10/10/2020", "time" : "14:00", "callerName" : "John Doe", "id" : ""]]))
    }
}
