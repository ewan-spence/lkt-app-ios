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
    let genderPref: Bool
    let ethnicity: String
    let ethnicPref: Bool
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
