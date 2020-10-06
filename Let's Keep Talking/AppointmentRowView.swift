//
//  AppointmentRowView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 06/10/2020.
//

import SwiftUI

struct AppointmentRowView: View {
    @State var callerName: String
    @State var callDate: String
    @State var callTime: String
    
    var body: some View {
        HStack{
            VStack {
                Text(callDate)
                Text(callTime)
            }.padding()
            Spacer()
            Button("Book Call", action: bookCall)
            
            Spacer()
            Text(callerName).padding(.trailing)
            
            
        }
    }
    
    func bookCall() -> Void {
        
    }
}

struct AppointmentRowView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRowView(callerName: "John Doe", callDate: "12/10/2020", callTime: "15:00")
    }
}
