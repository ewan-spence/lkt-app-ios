//
//  ClientFragmentViewTwo.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import SwiftUI

struct ClientFragmentViewTwo: View {
    var body: some View {
        NavigationView{
            VStack {
                Text("Welcome to the Let's Keep Talking App")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                if(!UserDefaults.standard.bool(forKey: "hasCalls")) {
                    
                    Text("You have no current calls booked, would you like to book one now?")
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    NavigationLink(destination: ClientCallBookerView(calls: [])) {
                        Text("Book Call")
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

struct ClientFragmentViewTwo_Previews: PreviewProvider {
    static var previews: some View {
        ClientFragmentViewTwo()
    }
}
