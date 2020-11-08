//
//  ContentView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 19/09/2020.
//

import SwiftUI

struct LandingView: View {
    @State var isLoggedIn: Bool = false
    @State var isLoggedInClient: Bool = false
    @State var isLoggedInCaller: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                Text("Welcome to the Let's Keep Talking App")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                
                
                VStack {
                    
                    
                    NavigationLink(destination: ClientView(hasDetailsSaved: isLoggedInClient)){
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
                    
                    NavigationLink(destination: CallerView(hasDetailsSaved: isLoggedInCaller)) {
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
            
        }.onAppear(perform: {
            update()
        })
        
    }
    
    func update() -> Void {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        isLoggedInClient = isLoggedInClientFunc(isLoggedIn)
        isLoggedInCaller = isLoggedInCallerFunc(isLoggedIn)
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
