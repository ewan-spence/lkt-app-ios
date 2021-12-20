//
//  AvailabilityCellView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 15/10/2020.
//

import SwiftUI

struct AvailabilityCellView: View {
    @State var day: String
    @State var time: String
    
    @Binding var week: [String: [String: [String: Bool]]]
    
    @State var isOn: Bool = false
    @State var isDisabled: Bool = false
    
    var body: some View {
        VStack {
            Text(time)
            
            Toggle(isOn: $isOn, label: {
                if(isOn) {
                    Text("Remove Availability")
                } else if(isDisabled){
                    Text("Call Booked")
                } else {
                    Text("Add Availability")
                }
            })
            .disabled(isDisabled)
        }
        .onChange(of: isOn, perform: {on in
            week[day]![time]!["isAvail"] = isOn
        })
        .onAppear(perform: {
            let dayDict = week[day]!
            
            isOn = dayDict[time]!["isAvail"]!
            isDisabled = dayDict[time]!["hasCall"]!
        })
    }
}

//struct AvailabilityCell_Previews: PreviewProvider {
//    static var previews: some View {
//        AvailabilityCellView(time: "09:30", isOnDict: .constant(["09:00" : true, "09:30" : false, "10:00" : false, "10:30" : false, "11:00" : true, "11:30" : false, "12:00" : false, "12:30" : false, "13:00" : true, "13:30" : true, "14:00" : true, "14:30" : false, "15:00" : true, "15:30" : false, "16:00" : true, "16:30" : false, "17:00" : false, "17:30" : true, "18:00" : false, "18:30" : false, "19:00" : false, "19:30" : true, "20:00" : true, "20:30" : false, "21:00" : true]))
//    }
//}
