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
        GeometryReader { geo in
            NavigationView {
                ZStack {
                    Color("background")
                        .ignoresSafeArea()
                    VStack {
                        
                        Spacer()
                        
                        Image("LKTLogo")
                            .resizable()
                            .scaledToFit()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack {
                            Spacer()
                            
                            NavigationLink(destination: ZStack {
                                Color("background").ignoresSafeArea()
                                ClientView(hasDetailsSaved: isLoggedInClient)
                            }) {
                                Text("Client Access")
                                    .font(Helpers.brandFont(size: 20))
                                    .foregroundColor(Color("text"))
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("text"), lineWidth: 3)
                            )
                            .shadow(radius: 10)
                            
                            Spacer()
                            
                            NavigationLink(destination: ZStack {
                                Color("background").ignoresSafeArea()
                                CallerView(hasDetailsSaved: isLoggedInCaller)
                            }) {
                                Text("Caller Access")
                                    .font(Helpers.brandFont(size: 20))
                                    .foregroundColor(Color("text"))
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("text"), lineWidth: 3)
                            )
                            .shadow(radius: 10)
                            
                            Spacer()
                        }
                    }
                }
            }
            .onAppear(perform: update)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // Update values for checking type/status of user
    func update() -> Void {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        isLoggedInClient = isLoggedInClientFunc(isLoggedIn)
        isLoggedInCaller = isLoggedInCallerFunc(isLoggedIn)
    }
    
    // Helper functions for the above
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
        //        LandingView().previewDevice("iPhone SE (2nd generation)")
        LandingView().previewDevice("iPhone XRs")
    }
}
