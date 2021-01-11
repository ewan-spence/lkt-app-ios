//
//  CallerLandingView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 29/09/2020.
//

import Alamofire
import SwiftUI

struct CallerLandingView: View {
    
    @State var isOnViewOne = false
    @State var isOnViewTwo = true
    @State var isOnViewThree = false
    
    @Binding var isLoggedIn: Bool
    @Binding var calls: [[String: String]]?
    
    @State var tempCalls: [[String: String]]?
    
    @Binding var availability: [String: [String]]?
    
    @State var isAlerting: Bool = false
    @State var alert: Alert = Alert(title: Text("Unknown Error"))
    
    @State var isAddingCallLength: Bool = false
    @State var callLength: String? = ""
    @State var callId: String = ""
    
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    
                    Menu(content: {
                        Button("Log Out", action: {
                            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                            UserDefaults.standard.removeObject(forKey: "userType")
                            UserDefaults.standard.removeObject(forKey: "phoneNo")
                            UserDefaults.standard.removeObject(forKey: "password")
                            UserDefaults.standard.removeObject(forKey: "id")
                            UserDefaults.standard.synchronize()
                            
                            isLoggedIn = false
                        })
                        .disabled(isLoading)
                    }, label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary)
                            .font(.system(size: 30))
                            .padding()
                            .onTapGesture(perform: {
                            })
                    })
                    .disabled(isLoading)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.clockwise").font(.system(size: 30))
                        .padding()
                        .onTapGesture(perform: {
                            getCalls(UserDefaults.standard.string(forKey: "id")!)
                        })
                }
                
                Spacer()
                
                if(isOnViewOne) {
                    CallerCallLogView(isAlerting: $isAlerting, callId: $callId, alert: $alert, calls: $calls)
                    
                }
                
                if(isOnViewTwo) {
                    
                    CallerHomeScreenView(calls: $calls, isAlerting: $isAlerting, alert: $alert)
                }
                
                if(isOnViewThree) {
                    CallerAvailabilityView(isOnViewTwo: $isOnViewTwo, isOnViewThree: $isOnViewThree, isAlerting: $isAlerting, alert: $alert)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    let viewOneIcon = ZStack {
                        Image(systemName: "phone")
                            .font(.system(size: 40))
                            .onTapGesture(perform: {
                                self.isOnViewOne = true
                                self.isOnViewTwo = false
                                self.isOnViewThree = false
                            })
                    }.padding()
                    
                    if(isOnViewOne) {
                        viewOneIcon.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 5)
                        )
                    } else {
                        viewOneIcon
                    }
                    
                    Spacer()
                    
                    let viewTwoIcon = ZStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .onTapGesture(perform: {
                                if(self.isOnViewThree) {
                                    alert = Alert(title: Text("Discard Changes?"), message: Text("Would you like to discard your changes?"), primaryButton: .destructive(Text("Yes"), action: {
                                        self.isOnViewOne = false
                                        self.isOnViewTwo = true
                                        self.isOnViewThree = false
                                    }), secondaryButton: .cancel(Text("No, Go Back")))
                                    
                                    isAlerting = true
                                    
                                } else {
                                    
                                    self.isOnViewOne = false
                                    self.isOnViewTwo = true
                                    self.isOnViewThree = false
                                }
                            })
                        
                    }.padding()
                    
                    
                    if(isOnViewTwo) {
                        viewTwoIcon.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 5))
                    } else {
                        viewTwoIcon
                    }
                    
                    Spacer()
                    
                    let viewThreeIcon = ZStack {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 40))
                            .onTapGesture(perform: {
                                self.isOnViewOne = false
                                self.isOnViewTwo = false
                                self.isOnViewThree = true
                            })
                        
                    }.padding()
                    
                    if(isOnViewThree) {
                        viewThreeIcon.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 5))
                    } else {
                        viewThreeIcon
                    }
                    
                    Spacer()
                }
            }
            
            if(isLoading) {
                ProgressView()
            }
        }
        .alert(isPresented: $isAlerting, content: {
            alert
        })
    }
    
    func getCalls(_ id: String) -> Void {
        tempCalls = calls
        calls = []
        isLoading = true
        
        let url = APIEndpoints.GET_CALLER_CALLS
        
        let params = ["id" : id]
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            switch(response.result) {
            case let .success(value):
                
                guard let json = value as? [String: Any] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                if(status) {
                    guard let array = json["result"] as? [[String: Any]] else {
                        return handleGetCallsResponse(false, #line, nil)
                    }
                    
                    return handleGetCallsResponse(true, nil, array)
                }
                
            case let .failure(error):
                debugPrint(error)
                return handleGetCallsResponse(false, #line, nil)
            }
        }
    }
    
    func handleGetCallsResponse(_ status: Bool, _ lineNo: Int?, _ result: [[String: Any]]?) {
        if(status) {
            
            result!.forEach { call in
                guard let callId = call["_id"] as? String else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let callDate = call["date"] as? String else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let callTime = call["time"] as? String else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let callClient = call["client"] as? [String: String] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let clientName = callClient["fullName"] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                guard let clientNumber = callClient["phoneNo"] else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                var newCall = ["id" : callId, "date" : callDate, "time" : callTime, "clientName" : clientName, "clientNo" : clientNumber]
                
                if let callLength = call["length"] as? String {
                    newCall["length"] = callLength
                }
                
                calls?.append(newCall)
                
            }
            
            alert = Alert(title: Text("Successfully Refreshed"), message: Text("Your call log has been refreshed"), dismissButton: .default(Text("Okay")))
            
        } else {
            calls = tempCalls
            alert = Alert(title: Text("Error"), message: Text("Problem retrieving call details - please try again.\nIf this error persists, contact support with error code 10\(lineNo!)"), dismissButton: .default(Text("Okay")))
        }
        
        isAlerting = true
        tempCalls = nil
        isLoading = false
    }
}

struct CallerLandingView_Previews: PreviewProvider {
    static var previews: some View {
        CallerLandingView(isLoggedIn: .constant(true), calls: .constant([]), availability: .constant([:]))
    }
}
