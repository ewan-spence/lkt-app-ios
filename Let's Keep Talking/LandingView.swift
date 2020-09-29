//
//  ContentView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 19/09/2020.
//

import SwiftUI

struct LandingView: View {    
    var body: some View {
        NavigationView {
            VStack {
                
                Text("Welcome to the Let's Keep Talking App")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                
                
                VStack {
                    let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
                    
                    let isLoggedInClient = isLoggedInClientFunc(isLoggedIn)
                    let isLoggedInCaller = isLoggedInCallerFunc(isLoggedIn)
                    
                    NavigationLink(destination: ClientView(isLoggedIn: isLoggedInClient)){
                        Text("Client Access")
                            .font(.system(size: 20))
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green, lineWidth: 3)
                    )
                    .shadow(radius: 10)
                    
                    Spacer().frame(height: 100)
                    
                    NavigationLink(destination: CallerView(isLoggedIn: isLoggedInCaller)) {
                        Text("Caller Access")
                            .font(.system(size: 20))
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green, lineWidth: 3)
                    )
                    .shadow(radius: 10)
                }
                
                Spacer()
                
            }
            
        }
        
    }
    
    func isLoggedInClientFunc(_ isLoggedIn: Bool) -> Bool {
        if let userType = UserDefaults.standard.string(forKey: "userType") {
            return (isLoggedIn && (userType.elementsEqual("client")))
        }
        return false
        
    }
    
    func isLoggedInCallerFunc(_ isLoggedIn: Bool) -> Bool{
        if let userType = UserDefaults.standard.string(forKey: "userType") {
            return (isLoggedIn && (userType.elementsEqual("caller")))
        }
        return false
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
