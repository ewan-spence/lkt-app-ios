//
//  SecureFieldToggle.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 20/12/2021.
//

import SwiftUI

struct SecureFieldToggle: View {
    @State var canSeeText: Bool = false
    
    @State var placeholder: String
    
    @Binding var text: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        ZStack {
            if (canSeeText) {
                TextField(placeholder, text: $text)
            } else {
                SecureField(placeholder, text: $text)
            }
            
            Toggle("", isOn: $canSeeText)
        }
    }
}

struct SecureFieldToggle_Previews: PreviewProvider {
    static var previews: some View {
        SecureFieldToggle("Text", text: .init(get: {
            return "Something"
        }, set: { val in
            return
        }))
            .previewDevice(.init(rawValue: "iPhone 13"))
    }
}
