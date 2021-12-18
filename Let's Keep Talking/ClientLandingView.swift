//
//  ClientLandingView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 26/09/2020.
//

import Alamofire
import SwiftUI

struct ClientLandingView: View {
    
    @State var isOnView1 = false
    @State var isOnView2 = true
    
    @State var isLoading = false
    
    @Binding var calls: [[String: String]]?
    
    @Binding var isLoggedIn: Bool
    
    @Binding var alert: Alert
    @Binding var isAlerting: Bool
    
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
                    })
                    .disabled(isLoading)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.clockwise").font(.system(size: 30))
                        .padding()
                        .onTapGesture(perform: {
                            getCalls(UserDefaults.standard.string(forKey: "id")!)
                        })
                }
                                
                if(isOnView1) {
                    ClientCallLogView(isAlerting: $isAlerting, alert: $alert, calls: $calls)
                }
                
                if(isOnView2) {
                    ClientHomeScreenView(calls: $calls, isAlerting: $isAlerting, alert: $alert)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    let viewOneIcon = ZStack {
                        Image(systemName: "phone")
                            .font(.system(size: 40))
                            .onTapGesture(perform: {
                                self.isOnView1 = true
                                self.isOnView2 = false
                            })
                    }.padding()
                    
                    if(isOnView1) {
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
                                self.isOnView1 = false
                                self.isOnView2 = true
                            })
                        
                    }.padding()
                    
                    if(isOnView2) {
                        viewTwoIcon.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 5))
                    } else {
                        viewTwoIcon
                    }
                    
                    Spacer()
                }
            }
            
            if(isLoading) {
                ProgressView()
            }
        }
        
    }
    
    func getCalls(_ clientId: String?) {
        isLoading = true
        
        AF.request(APIEndpoints.GET_CLIENT_CALLS, method: .post, parameters: ["id" : clientId], encoder: JSONParameterEncoder.default).responseJSON { response in
            switch response.result {
            case let .success(value):
                
                guard let dict = value as? [String: Any] else  {
                    return handleGetCallsResponse(false, #line, nil)

                }
                
                guard let status = dict["status"] as? Bool else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                if(status) {
                    
                    
                    guard let callDicts = dict["result"] as? [[String:Any]] else {
                        return handleGetCallsResponse(false, #line, nil)
                    }
                    
                    var funcCalls: [[String: String]] = []
                    
                    callDicts.forEach { callDict in
                        
                        guard let callTimeString = callDict["time"] as? String else {
                            return handleGetCallsResponse(false, #line, nil)
                        }
                        
                        guard let callDateString = callDict["date"] as? String else {
                            return handleGetCallsResponse(false, #line, nil)
                        }
                        
                        guard let callIdString = callDict["_id"] as? String else {
                            return handleGetCallsResponse(false, #line, nil)
                        }
                        
                        guard let callCallerDict = callDict["caller"] as? [String: String]  else{
                            return handleGetCallsResponse(false, #line, nil)
                        }
                        
                        guard let callCallerString = callCallerDict["fullName"] else {
                            return handleGetCallsResponse(false, #line, nil)
                        }
                        
                        var hasRatingString = ""
                        
                        if Helpers.isInFuture(callDateString, callTimeString) || callDict["rating"] == nil {
                            hasRatingString = "F"
                        } else {
                            hasRatingString = "T"
                        }
                        
                        var funcCall = ["date" : callDateString , "time" : callTimeString , "callerName" : callCallerString, "id" : callIdString, "hasRating" : hasRatingString]
                        
                        if let hasNotif = callDict["hasNotif"] as? Bool {
                            if hasNotif {
                                guard let notifTime = callDict["notifTime"] else {
                                    return handleGetCallsResponse(false, #line, nil)
                                }
                                
                                if "\(notifTime)" != "<null>" {
                                    funcCall["notifTime"] = "\(notifTime)"
                                }
                            }
                        }
                        
                        funcCalls.append(funcCall)
                    }
                    
                    handleGetCallsResponse(true, nil, funcCalls)
                    
                } else {
                    return handleGetCallsResponse(false, #line, nil)
                }
                
                
            case .failure(_):
                return handleGetCallsResponse(false, #line, nil)
            }
        }
    }
    
    func handleGetCallsResponse(_ status: Bool, _ lineNo: Int?, _ result: [[String: String]]?) {
        if(status) {
            calls = result
            
            alert = Alert(title: Text("Successfully Refreshed"), message: Text("Your call log has been refreshed"), dismissButton: .default(Text("Okay")))
            
        } else {
            alert = Alert(title: Text("Error"), message: Text("Problem retrieving call details - please try again.\nIf this error persists, contact support with error code 0\(lineNo!)"), dismissButton: .default(Text("Okay")))
        }
        
        isLoading = false
        isAlerting = true
    }
    
    struct ClientLandingView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ClientLandingView(calls: .constant([]), isLoggedIn: .constant(true), alert: .constant(Alert(title: Text("Alert"))), isAlerting: .constant(false))
                    .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
                    .previewDisplayName("iPhone 7")
                
                ClientLandingView(calls: .constant([]), isLoggedIn: .constant(true), alert: .constant(Alert(title: Text("Alert"))), isAlerting: .constant(false))
                    .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                    .previewDisplayName("iPhone 12")
            }
        }
    }

}
