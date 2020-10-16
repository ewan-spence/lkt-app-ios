//
//  AvailabilityColView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 15/10/2020.
//

import SwiftUI

struct AvailabilityColView: View {
    
    @State var day: String
    
    @Binding var week: [String : [String : [String : Bool]]]
    
    var body: some View {
        VStack {
            Text(day)
                .padding()
            
            Divider()
            
            let dayDict = week[day]
            
            let timesList = dayDict?.keys.reversed()
            let sortedTimesList = sortTimes(timesList!)
            
            ForEach(sortedTimesList, id: \.self) { time in
                AvailabilityCellView(day: day, time: time, week: $week)
                    .padding()
            }
        }
    }
    
    func sortTimes(_ times: [String]) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "HH:mm"
        
        let timesAsDates = times.map(formatter.date(from:))
        
        let timesSorted = timesAsDates.sorted(by: { $0!.compare($1!) == .orderedAscending })
        
        return timesSorted.map({ formatter.string(from: $0!)})
    }
}

//struct AvailabilityColView_Previews: PreviewProvider {
//    static var previews: some View {
//        AvailabilityColView(day: "Monday", times: ["09:00" : true, "09:30" : false, "10:00" : false, "10:30" : false, "11:00" : true, "11:30" : false, "12:00" : false, "12:30" : false, "13:00" : true, "13:30" : true, "14:00" : true, "14:30" : false, "15:00" : true, "15:30" : false, "16:00" : true, "16:30" : false, "17:00" : false, "17:30" : true, "18:00" : false, "18:30" : false, "19:00" : false, "19:30" : true, "20:00" : true, "20:30" : false, "21:00" : true])
//    }
//}
