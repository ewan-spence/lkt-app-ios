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
        let days = week.map{$0.key}
        let daysSorted = sortDays(days)
        
        VStack {
        
            
            
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

struct WeekOneView_Previews: PreviewProvider {
    static var previews: some View {
        let week = ["Monday" : ["09:00" : ["isAvail": true, "hasCall": false], "09:30" : ["isAvail": true, "hasCall": false], "10:00" : ["isAvail": true, "hasCall": false], "10:30" : ["isAvail": true, "hasCall": false], "11:00" : ["isAvail": true, "hasCall": false], "11:30" : ["isAvail": true, "hasCall": false], "12:00" : ["isAvail": true, "hasCall": false], "12:30" : ["isAvail": true, "hasCall": false], "13:00" : ["isAvail": true, "hasCall": false], "13:30" : ["isAvail": true, "hasCall": false], "14:00" : ["isAvail": true, "hasCall": false], "14:30" : ["isAvail": true, "hasCall": false], "15:00" : ["isAvail": true, "hasCall": false], "15:30" : ["isAvail": true, "hasCall": false], "16:00" : ["isAvail": true, "hasCall": false], "16:30" : ["isAvail": true, "hasCall": false], "17:00" : ["isAvail": true, "hasCall": false], "17:30" : ["isAvail": true, "hasCall": false], "18:00" : ["isAvail": true, "hasCall": false], "18:30" : ["isAvail": true, "hasCall": false], "19:00" : ["isAvail": true, "hasCall": false], "19:30" : ["isAvail": true, "hasCall": false], "20:00" : ["isAvail": true, "hasCall": false], "20:30" : ["isAvail": true, "hasCall": false], "21:00" : ["isAvail": true, "hasCall": false]]]
        
        WeekView(week: .constant(week))
    }
}
