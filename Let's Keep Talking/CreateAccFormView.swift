//
//  CreateAccFormView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 30/09/2020.
//

import SwiftUI

struct CreateAccFormView: View {
    @Binding var fullName: String
    @Binding var phoneNo: String
    @Binding var phoneConf: String
    @Binding var password: String
    @Binding var passwordConf: String
    @Binding var gender: String
    @Binding var genderOptOut: Bool
    @Binding var genderPref: String
    @Binding var ethnicity: String
    @Binding var ethnicOptOut: Bool
    @Binding var bme: Bool
    @Binding var ethnicPref: Bool
    
    @State var showHelp: Bool
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: true, content: {
                
                HStack {
                    Text("* Required")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.leading)
                    Spacer()
                }
                
                TextField("Full Name *", text: $fullName)
                    .padding()
                
                
                TextField("Phone Number *", text: $phoneNo)
                    .padding()
                    .keyboardType(.numberPad)
                
                TextField("Confirm Phone Number *", text: $phoneConf)
                    .padding()
                    .keyboardType(.numberPad)
                
                
                SecureField("Password *", text: $password)
                    .padding()
                
                SecureField("Confirm Password *", text: $passwordConf)
                    .padding()
                
                
                HStack {
                    TextField("Gender", text: $gender)
                        .padding()
                        .disabled(genderOptOut)
                        .onChange(of: genderOptOut, perform: { value in
                            if(value) {
                                self.gender = ""
                            }
                        })
                    
                    Toggle(isOn: $genderOptOut, label: {
                        Text("Prefer not to Specify")
                            .foregroundColor(.gray)
                    })
                    .padding(.trailing)
                }
                
                Dropdown(displayText: "Gender Preference", options: .constant(["Male", "Female", "No Preference"]), selectedItem: $genderPref)
                
                HStack {
                    TextField("Ethnicity", text: $ethnicity)
                        .padding()
                        .disabled(ethnicOptOut)
                        .onChange(of: ethnicOptOut, perform: { value in
                            if(value) {
                                self.ethnicity = ""
                            }
                        })
                    
                    Toggle(isOn: $ethnicOptOut, label: {
                        Text("Prefer not to Specify")
                            .foregroundColor(.gray)
                    })
                    .padding(.trailing)
                }
                
                if(!ethnicity.isEmpty){
                    Toggle(isOn: $bme, label: {
                        Text("I identify as an ethnic minority")
                            .foregroundColor(.gray)
                    })
                    .padding()
                    
                    if(bme) {
                        Toggle(isOn: $ethnicPref, label: {
                            Text("I would like an ethnic minority caller")
                                .foregroundColor(.gray)
                                .alert(isPresented: $showHelp, content: {
                                    Alert(title: Text("Info"), message: Text("We have a small, but growing, number of ethnic minority callers. If you select this option, we will do our best to find a caller of a similar ethnicity to you. We may phone to arrange this."), dismissButton: .default(Text("Got it!")))
                                })
                        }).onTapGesture(perform: {
                            showHelp = !ethnicPref
                        })
                        .padding()
                        
                    }
                }
            })
        }
    }
}

struct HelpText: View {
    @Binding var showHelp: Bool
    
    var body: some View {
        if(showHelp) {
            VStack {
                Spacer()
                Text("We have a small, but growing, number of ethnic minority callers. If you select this option, we will do our best to find a caller of a similar ethnicity to you. We may phone to arrange this.")
            }
        }
    }
}


struct CreateAccFormView_Previews: PreviewProvider {
    
    static var previews: some View {
        CreateAccFormView(fullName: .constant(""), phoneNo: .constant(""), phoneConf: .constant(""), password: .constant(""), passwordConf: .constant(""), gender: .constant(""), genderOptOut: .constant(false), genderPref: .constant(""), ethnicity: .constant(""), ethnicOptOut: .constant(false), bme: .constant(false), ethnicPref: .constant(false), showHelp: false)
    }
}
