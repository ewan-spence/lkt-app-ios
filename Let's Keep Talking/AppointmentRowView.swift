//
//  AppointmentRowView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 09/10/2020.
//

import SwiftUI
import Alamofire

struct AppointmentRowView: View {
    
    @State var call: [String: String]
    
    @State var isClient: Bool
    @State var isOnCallLog: Bool?
    @State var addTimeIsOpen: Bool = false
    
    @State var callLength: String? = ""
    
    @State var isAlerting: Bool = false
    @State var alertTitle: String = ""
    @State var alertText: String = ""
    
    @State var isAddingCallLength: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Text(Helpers.getDayOfWeek(dateString: call["date"]!))
                    Text(call["date"] ?? "")
                    Text(call["time"] ?? "")
                }.padding()
                
                Spacer()
                
                if(isClient) {
                    NavigationLink("Rate Call", destination: CallRaterView())
                        .disabled(isInFuture(call["date"]!, call["time"]!))
                    Spacer()
                    Text(call["callerName"]!).padding(.trailing)
                    
                    
                } else if(isOnCallLog!){
                    
                    Button("Add Call Length", action: {isAddingCallLength = true})
                        .textFieldAlert(isPresented: $isAddingCallLength, content: {
                            TextFieldAlert(title: "Add Call Length", message: nil, text: $callLength, action: {
                                addCallLength(callLength!)
                            })
                        })
                        .alert(isPresented: $isAlerting, content: {
                            Alert(title: Text(alertTitle), message: Text(alertText), dismissButton: .default(Text("Okay")))
                        })
                        .disabled(isInFuture(call["date"]!, call["time"]!) || !((call["length"]?.isEmpty) ?? false))
                    
                    Spacer()
                    Text(call["clientName"]!).padding(.trailing)
                    
                } else {
                    
                    Button("Call Client", action: {
                        let prefix = "tel://"
                        
                        let formattedPhoneNo = prefix + call["clientNo"]!
                        
                        UIApplication.shared.open(URL(string: formattedPhoneNo)!)
                    })
                    
                    Spacer()
                    Text(call["clientName"]!).padding(.trailing)
                }
                
            }
            if(isLoading) {
                ProgressView()
            }
        }
        .onAppear(perform: {
            callLength = call["length"] ?? ""
        })
    }
    
    func addCallLength(_ length: String) {
        isLoading = true
        
        let url = APIEndpoints.ADD_CALL_LENGTH
        
        guard let callId = call["id"] else {
            return addLengthResponse(false, #line, nil)
        }
        
        let params = ["id" : callId, "length" : callLength]
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch(response.result) {
            case let .success(value):
                guard let json = value as? [String: Any] else {
                    return addLengthResponse(false, #line, nil)
                }
                
                guard let status = json["status"] as? Bool else {
                    return addLengthResponse(false, #line, nil)
                }
                
                guard let result = json["result"] as? [String: Any] else {
                    return addLengthResponse(false, #line, nil)
                }
                
                if(status) {
                    return addLengthResponse(true, nil, result)
                } else {
                    return addLengthResponse(false, #line, nil)
                }
            case .failure(_):
                return addLengthResponse(false, #line, nil)
            }
        }
    }
    
    func addLengthResponse(_ status: Bool, _ lineNo: Int?, _ result: [String: Any]?) {
        if(status) {
            alertTitle = "Length Added"
            alertText = "Thank you for adding this call length"
        } else {
            alertTitle = "Error"
            alertText = "There was an error - please reload the app.\nIf this error persists please contact support with code 0" + String(lineNo!)
        }
        isAlerting = true
        isLoading = false
    }
    
    func isInFuture(_ date: String, _ time: String) -> Bool {
        if(date.elementsEqual("") || time.elementsEqual("")) {
            return true
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let fullDate = date + " " + time
        let dateAsObj = formatter.date(from: fullDate)
        
        let today = Date(timeIntervalSinceNow: 0)
        
        return dateAsObj?.timeIntervalSince(today) ?? 0 > 0
    }
}

struct AppointmentRowView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRowView(call: ["date" : "19/10/2020", "time" : "14:00", "clientName" : "John Doe", "id" : "", "length" : "15"], isClient: false, isOnCallLog: true)
    }
}
