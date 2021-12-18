//
//  AlertPicker.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 08/01/2021.
//

import SwiftUI

struct AlertPicker: View {
    @Binding var chosenNumMinutes: Int
    
    @State var hours: Int = 0
    @State var minutes: Int = 0
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Picker("Hour", selection: $hours, content: {
                    ForEach(0..<4, content: {hour in
                        if hour == 1 {
                            Text("\(hour) hour")
                                .font(Helpers.brandFont(size: 20)).foregroundColor(Color("text"))
                        } else {
                            Text("\(hour) hours")
                                .font(Helpers.brandFont(size: 20)).foregroundColor(Color("text"))
                        }
                    })
                })
                    .frame(width:geo.size.width/2)
                Picker("Minute", selection: $minutes, content: {
                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self, content: {minute in
                        if minute == 1 {
                            Text("\(minute) minute")
                                .font(Helpers.brandFont(size: 20)).foregroundColor(Color("text"))
                        } else {
                            Text("\(minute) minutes")
                                .font(Helpers.brandFont(size: 20)).foregroundColor(Color("text"))
                        }
                    })
                })
                    .frame(width:geo.size.width/2)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .onChange(of: [hours, minutes], perform: { value in
            chosenNumMinutes = hours*60 + minutes
        })
    }
}
