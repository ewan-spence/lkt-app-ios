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
    @State var isOnView3 = false
    
    @State var menuShown = false
    
    @Binding var isLoggedIn: Bool
    
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
                        UserDefaults.standard.synchronize()
                        
                        isLoggedIn = false
                    })
                })
                }
                
                Spacer()
            }
            
            Spacer()
            
            if(isOnView1) {
                ClientFragmentViewOne()
            }
            
            if(isOnView2) {
                ClientFragmentViewTwo()
            }
            
            if(isOnView3) {
                ClientFragmentViewThree()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                let viewOneIcon = ZStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 40))
                        .onTapGesture(perform: {
                            self.isOnView1 = true
                            self.isOnView2 = false
                            self.isOnView3 = false
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
                            self.isOnView3 = false
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
                
                let viewThreeIcon = ZStack {
                    Image(systemName: "phone")
                        .font(.system(size: 40))
                        .onTapGesture(perform: {
                            self.isOnView1 = false
                            self.isOnView2 = false
                            self.isOnView3 = true
                            self.menuShown = false
                        })
                }.padding()
                
                if(isOnView3) {
                    viewThreeIcon.overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 5))
                } else {
                    viewThreeIcon
                }
                
                Spacer()
            }
        }
        
    }
}

struct ClientLandingView_Previews: PreviewProvider {
    static var previews: some View {
        ClientLandingView(isLoggedIn: .constant(true))
    }
}
