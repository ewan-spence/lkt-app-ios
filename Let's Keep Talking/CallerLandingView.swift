//
//  CallerLandingView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 29/09/2020.
//

import SwiftUI

struct CallerLandingView: View {
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
        }
    }
}

struct CallerLandingView_Previews: PreviewProvider {
    static var previews: some View {
        CallerLandingView(isLoggedIn: .constant(true))
    }
}
