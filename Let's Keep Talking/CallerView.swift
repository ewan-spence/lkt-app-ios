//
//  CallerView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 27/09/2020.
//

import SwiftUI

struct CallerView: View {
    @State var isLoggedIn: Bool
    
    var body: some View {
        if(isLoggedIn) {
            ClientLandingView(isLoggedIn: $isLoggedIn)
        } else {
            CallerLoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct CallerView_Previews: PreviewProvider {
    static var previews: some View {
        CallerView(isLoggedIn: false)
    }
}
