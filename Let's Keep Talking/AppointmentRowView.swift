//
//  AppointmentRowView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 09/10/2020.
//

import SwiftUI
import Alamofire

struct AppointmentRowView: View {
    
    @State var isAddingCallLength: Bool = false
    @State var callLength: String? = ""
    
    @State var call: [String: String]
    
    @State var isClient: Bool
    @State var isOnCallLog: Bool
        
    @Binding var isAlerting: Bool
    @Binding var alert: Alert
    
    @State var callId: String
    @State var hasRating: Bool = false
        
    @Binding var isLoading: Bool
    
    @Binding var calls: [[String: String]]?
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack {
                    Text(Helpers.getDayOfWeek(dateString: call["date"]!))
                    Text(call["date"] ?? "")
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text(call["time"] ?? "")
                }.padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                
                if(isClient) {
                    
                    if(!Helpers.isInFuture(call["date"]!, call["time"]!)) {
                        NavigationLink("Rate Call", destination: CallRaterView(hasRating: $hasRating, callId: callId))
                            .disabled((call["hasRating"] == "T") || hasRating || isLoading)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    } else {
                        Button("Cancel Call", action: {
                            
                            alert = Alert(title: Text("Confirm Cancellation"), message: Text("Are you sure you wish to cancell this call?"), primaryButton: .destructive(Text("Yes"), action: cancelCall), secondaryButton: .cancel(Text("No")))
                            
                            isAlerting = true
                        })
                        .disabled(isLoading)
                        .alert(isPresented: $isAlerting) {
                            alert
                        }
                    }
                    
                    VStack {
                        Text(call["callerName"]!).padding(.trailing)
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    
                    
                    
                    
                } else if(isOnCallLog){
                    
                    VStack {
                        if(!Helpers.isInFuture(call["date"]!, call["time"]!)) {
                            
                            if(call["length"] == nil || call["length"]!.isEmpty) {
                                Button("Add Call Length", action: {
                                    isAddingCallLength = true
                                    callLength = call["length"] ?? ""
                                    callId = call["id"]!
                                })
                                .textFieldAlert(isPresented: $isAddingCallLength, content: {
                                    TextFieldAlert(title: "Add Call Length", message: "Please enter the call length below", text: $callLength, action: {
                                        addCallLength()
                                    })
                                })
                                .disabled(isLoading)
                            } else {
                                Button("Edit Call Length", action: {
                                    isAddingCallLength = true
                                    callLength = call["length"]
                                    callId = call["id"]!
                                })
                                .textFieldAlert(isPresented: $isAddingCallLength, content: {
                                    TextFieldAlert(title: "Edit Call Length", message: "Please adjust the call length below", text: $callLength, action: {
                                        addCallLength()
                                    })
                                })
                                .disabled(isLoading)
                            }
                        } else {
                            Button("Cancel Call", action: {
                                alert = Alert(title: Text("Confirm Cancellation"), message: Text("Are you sure you wish to cancell this call?"), primaryButton: .destructive(Text("Yes"), action: cancelCall), secondaryButton: .cancel(Text("No")))
                                
                                isAlerting = true
                            })
                            .disabled(isLoading)
                        }
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    
                    
                    VStack {
                        Text(call["clientName"]!).padding(.trailing)
                        
                        if(call["length"] != nil && !(call["length"] == "")){
                            Text(call["length"]! + " mins").padding(.trailing)
                        }
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    
                } else {
                    
                    VStack {
                        Button("Call Client", action: {
                            let prefix = "tel://141"
                            
                            let formattedPhoneNo = prefix + call["clientNo"]!
                            
                            UIApplication.shared.open(URL(string: formattedPhoneNo)!)
                        })
                        .disabled(isLoading)
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    
                    
                    VStack {
                        Text(call["clientName"]!).padding(.trailing)
                    }.frame(minWidth: 0, maxWidth: .infinity)
                }
                
            }
        }
        .onAppear(perform: {
            callLength = call["length"] ?? ""
            callId = call["id"] ?? ""
        })
        .onChange(of: callLength, perform: {length in
            if(callId == call["id"]!) {
                call["length"] = callLength
            }
        })
    }
    
    
    func cancelCall() {
        isLoading = true
        
        let url = APIEndpoints.CANCEL_CALL
        
        AF.request(url, method: .post, parameters: call, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                debugPrint(value)
                
                guard let json = value as? [String: Any?] else {
                    return handleCancelResponse(false, #line)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleCancelResponse(false, #line)
                }
                
                return handleCancelResponse(status, #line)
                
            case let .failure(error):
                debugPrint(error)
                
                return handleCancelResponse(false, #line)
            }
        }
    }
    
    func handleCancelResponse(_ status: Bool, _ line: Int) {
        if(status) {
            
            calls?.remove(at: (calls?.firstIndex(of: call))!)
            
            alert = Alert(title: Text("Call Cancelled"), message: Text("Your call with " + call["clientName"]! + " has been cancelled."), dismissButton: .default(Text("Okay")))
        } else {
            alert = Alert(title: Text("Error"), message: Text("Error cancelling call. Please reload app and try again.\nIf this problem persists, contact support with error code 5" + String(line)), dismissButton: .default(Text("Okay")))
        }
        isLoading = false
        isAlerting = true
    }
    
    func addCallLength() {
        isLoading = true
        let url = APIEndpoints.ADD_CALL_LENGTH
        
        let params = ["id" : callId, "length": callLength!]
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                guard let json = value as? [String: Any] else {
                    return handleAddLengthResponse(false, #line)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleAddLengthResponse(false, #line)
                }
                
                if(status) {
                    return handleAddLengthResponse(true, nil)
                } else {
                    return handleAddLengthResponse(false, #line)
                }
            case let .failure(error):
                debugPrint(error)
                return handleAddLengthResponse(false, #line)
            }
        }
    }
    
    func handleAddLengthResponse(_ status: Bool, _ lineNo: Int?) -> Void {
        if(status) {
            alert = Alert(title: Text("Call Length Added"), message: Text("The call has been edited successfully"), dismissButton: .default(Text("Okay")))
        } else {
            alert = Alert(title: Text("Error"), message: Text("There was an error editing the call - please try again.\nIf this error persists, please contact support with error code 6\(lineNo!)"), dismissButton: .default(Text("Okay")))
        }
        isAlerting = true
        isLoading = false
    }
}
