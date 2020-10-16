//
//  WeekView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 15/10/2020.
//

import SwiftUI

struct WeekView: View {
    @Binding var week: [String: [String: [String: Bool]]]
    
    var body: some View {
        ScrollView {
            let days = week.map{$0.key}
            let daysSorted = sortDays(days)
            
            
            ScrollView(.horizontal) {
                
                HStack {
                    ForEach(daysSorted, id: \.self) {day in
                        AvailabilityColView(day: day, week: $week)
                            .padding()
                    }
                }
            }
            
        }
    }
    
    func sortDays(_ days: [String]) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "dd/MM/yyyy"
        
        var dates = days.map({ formatter.date(from: $0) })
        
        dates.sort(by: { $0!.compare($1!) == .orderedAscending })
        
        return dates.map({ formatter.string(from: $0!)})
    }
}
//
//struct WeekOneView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeekView(week: .constant(["Monday" : ["09:00" : true, "09:30" : false, "10:00" : false, "10:30" : false, "11:00" : true, "11:30" : false, "12:00" : false, "12:30" : false, "13:00" : true, "13:30" : true, "14:00" : true, "14:30" : false, "15:00" : true, "15:30" : false, "16:00" : true, "16:30" : false, "17:00" : false, "17:30" : true, "18:00" : false, "18:30" : false, "19:00" : false, "19:30" : true, "20:00" : true, "20:30" : false, "21:00" : true]]))
//    }
//}
