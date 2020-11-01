//
//  ClientLandingView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import SwiftUI

struct ClientLandingView: View {
    
    @State var isOnView1 = false
    @State var isOnView2 = true
    
    @State var menuShown = false
    
    @State var isLoading = false
    
    @Binding var calls: [[String: String]]?
    
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        ZStack {
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
                                
                if(isOnView1) {
                    ClientCallLogView(calls: $calls)
                }
                
                if(isOnView2) {
                    let latestCall = calls?.last
                    
                    let latestCallDate = latestCall?["date"]
                    let callTime = latestCall?["time"]
                    let callCaller = latestCall?["callerName"]
                    let callId = latestCall?["id"]
                    
                    ClientHomeScreenView(callDate: latestCallDate ?? "", callTime: callTime ?? "", callCaller: callCaller ?? "", callId: callId ?? "", calls: $calls)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    let viewOneIcon = ZStack {
                        Image(systemName: "phone")
                            .font(.system(size: 40))
                            .onTapGesture(perform: {
                                self.isOnView1 = true
                                self.isOnView2 = false
                                self.menuShown = false
                            })
                    }.padding()
                    
                    if(isOnView1) {
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
                                self.isOnView1 = false
                                self.isOnView2 = true
                                self.menuShown = false
                            })
                        
                    }.padding()
                    
                    if(isOnView2) {
                        viewTwoIcon.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 5))
                    } else {
                        viewTwoIcon
                    }
                    
                    Spacer()
                }
            }
            
            if(isLoading) {
                ProgressView()
            }
        }
        
    }
}

struct ClientLandingView_Previews: PreviewProvider {
    static var previews: some View {
        ClientLandingView(calls: .constant([[:]]), isLoggedIn: .constant(true))
    }
}
