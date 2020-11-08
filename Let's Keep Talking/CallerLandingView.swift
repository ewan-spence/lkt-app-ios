//
//  CallerLandingView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 29/09/2020.
//

import SwiftUI

struct CallerLandingView: View {
    @State var menuShown = false
    
    @State var isOnViewOne = false
    @State var isOnViewTwo = true
    @State var isOnViewThree = false
    
    @Binding var isLoggedIn: Bool
    @Binding var calls: [[String: String]]?
    @Binding var availability: [String: [String]]?
    
    @State var isAlerting: Bool = false
    @State var alert: Alert = Alert(title: Text("Unknown Error"))
    
    @State var isAddingCallLength: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "gearshape").font(.system(size: 30))
                    .padding()
                    .onTapGesture(perform: {
                        menuShown.toggle()
                    })
                
                if(menuShown) {
                    Menu("Settings", content: {
                        Button("Log Out", action: {
                            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                            UserDefaults.standard.removeObject(forKey: "userType")
                            UserDefaults.standard.removeObject(forKey: "phoneNo")
                            UserDefaults.standard.removeObject(forKey: "password")
                            UserDefaults.standard.removeObject(forKey: "id")
                            UserDefaults.standard.synchronize()
                            
                            isLoggedIn = false
                        })
                    })
                }
                
                Spacer()
            }
            
            Spacer()
            
            if(isOnViewOne) {
                CallerCallLogView(isAlerting: $isAlerting, isAddingCallLength: $isAddingCallLength, alert: $alert, calls: $calls)
            }
            
            if(isOnViewTwo) {
                CallerHomeScreenView(calls: $calls, isAlerting: $isAlerting, alert: $alert)
            }
            
            if(isOnViewThree) {
                CallerAvailabilityView(isOnViewTwo: $isOnViewTwo, isOnViewThree: $isOnViewThree, isAlerting: $isAlerting, alert: $alert)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                let viewOneIcon = ZStack {
                    Image(systemName: "phone")
                        .font(.system(size: 40))
                        .onTapGesture(perform: {
                            self.isOnViewOne = true
                            self.isOnViewTwo = false
                            self.isOnViewThree = false
                            self.menuShown = false
                        })
                }.padding()
                
                if(isOnViewOne) {
                    viewOneIcon.overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 5)
                    )
                } else {
                    viewOneIcon
                }
                
                Spacer()
                
                let viewTwoIcon = ZStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .onTapGesture(perform: {
                            self.isOnViewOne = false
                            self.isOnViewTwo = true
                            self.isOnViewThree = false
                            self.menuShown = false
                        })
                    
                }.padding()
                
                
                if(isOnViewTwo) {
                    viewTwoIcon.overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 5))
                } else {
                    viewTwoIcon
                }
                
                Spacer()
                
                let viewThreeIcon = ZStack {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .onTapGesture(perform: {
                            self.isOnViewOne = false
                            self.isOnViewTwo = false
                            self.isOnViewThree = true
                            self.menuShown = false
                        })
                    
                }.padding()
                
                if(isOnViewThree) {
                    viewThreeIcon.overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 5))
                } else {
                    viewThreeIcon
                }
                
                Spacer()
            }
        }
        .alert(isPresented: $isAlerting, content: {
            alert
        })
    }
}

struct CallerLandingView_Previews: PreviewProvider {
    static var previews: some View {
        CallerLandingView(isLoggedIn: .constant(true), calls: .constant([]), availability: .constant([:]))
    }
}
