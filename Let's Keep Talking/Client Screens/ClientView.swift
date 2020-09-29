//
//  ClientView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import SwiftUI

struct ClientView: View {
    @State var isLoggedIn: Bool
    
    var body: some View {
        if(isLoggedIn) {
            ClientLandingView(isLoggedIn: $isLoggedIn)
                .navigationBarHidden(true)
                .navigationTitle("")
        } else {
            ClientLoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct ClientView_Previews: PreviewProvider {
    static var previews: some View {
        ClientView(isLoggedIn: true)
    }
}
