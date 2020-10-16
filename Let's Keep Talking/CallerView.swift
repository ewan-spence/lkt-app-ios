//
//  CallerView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 27/09/2020.
//

import SwiftUI

struct CallerView: View {
    @State var isLoggedIn: Bool = false

    @State var hasDetailsSaved: Bool
    
    @State var calls: [[String: String]]?
    @State var availability: [String: [String]]?
    
    var body: some View {
        if(isLoggedIn) {
            CallerLandingView(isLoggedIn: $isLoggedIn, calls: $calls, availability: $availability)
                .navigationBarHidden(true)
                .navigationTitle("")
        } else {
            CallerLoginView(hasDetailsSaved: hasDetailsSaved, isLoggedIn: $isLoggedIn, calls: $calls, availability: $availability)
        }
    }
}

struct CallerView_Previews: PreviewProvider {
    static var previews: some View {
        CallerView(hasDetailsSaved: false)
    }
}
