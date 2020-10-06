//
//  Structs.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 28/09/2020.
//

import SwiftUI

struct Structs: View {
    var body: some View {
        EmptyView()
    }
}

struct LoginStruct: Encodable {
    let phoneNo: String
    let password: String
}

struct CreateAccStruct: Encodable {
    let phoneNo: String
    let password: String
    let gender: String
    let genderPref: String
    let ethnicity: String
    let ethnicPref: Bool
}

struct AvailStruct: Encodable {
    let callerSelected: Bool
    let callerName: String
    let clientId: String
}

struct Dropdown: View {
    @State var expand = false
    @State var displayText: String
    
    @Binding var options: [String]
    
    @Binding var selectedItem: String
    
    var body: some View {
        
        VStack{
            HStack {
                Text(displayText)
                    .foregroundColor(.blue)
                
                
                if(expand) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.blue)
                }
                
            }
            .onTapGesture(perform: {
                expand.toggle()
            })
            .padding()
            
            if(expand) {
                
                ForEach(options, id: \.self) { value in
                    Text(value)
                        .onTapGesture(perform: {
                            displayText = value
                            selectedItem = value
                            expand = false
                        })
                        .padding(.bottom)
                }
                
            }
        }
        
    }
}


enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
