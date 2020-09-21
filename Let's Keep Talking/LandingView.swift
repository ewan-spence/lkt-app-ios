//
//  ContentView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 19/09/2020.
//

import SwiftUI

struct LandingView: View {    
    var body: some View {
        NavigationView{
            VStack {
                
                Text("Welcome to the Let's Keep Talking App")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                

                VStack {
                    NavigationLink(destination: ClientLoginView()){
                        Text("Client Login")
                            .font(.system(size: 20))
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green, lineWidth: 3)
                    )
                    .shadow(radius: 10)
                    
                    Spacer().frame(height: 100)
                    
                    NavigationLink(destination: CallerLoginView()) {
                        Text("Caller Login")
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
        .frame(maxHeight: .infinity)
        .colorScheme(.dark)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
