//
//  ClientView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import SwiftUI
import Alamofire

struct ClientView: View {
    @State var isLoggedIn: Bool = false
    
    @State var hasDetailsSaved: Bool
    
    @State var calls: [[String: String]]?
    
    @State var alert: Alert = Alert(title: Text("Unknown Error"))
    @State var isAlerting: Bool = false
    
    var body: some View {
        if(isLoggedIn) {
            ClientLandingView(calls: $calls, isLoggedIn: $isLoggedIn, alert: $alert, isAlerting: $isAlerting)
                .navigationBarHidden(true)
                .navigationTitle("")
                .alert(isPresented: $isAlerting, content: {
                    alert
                })
            
        } else {
            ClientLoginView(hasDetailsSaved: hasDetailsSaved, calls: $calls, isLoggedIn: $isLoggedIn)
        }
    }
}

struct ClientView_Previews: PreviewProvider {
    static var previews: some View {
        ClientView(isLoggedIn: true, hasDetailsSaved: false)
    }
}
