//
//  CallRaterView.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 09/10/2020.
//

import Alamofire
import SwiftUI

struct CallRaterView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var callId: String
    @State var rating: Float = 5
    @State var feedback: String = ""
    
    @Binding var alert: Alert
    @Binding var isAlerting: Bool
    
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack {
            Text("Rate Call")
                .font(.largeTitle)
        Form {
            Text("Please rate your call on a scale from 0 to 10\nWhere 0 is \"Not at all helpful\"\nAnd 10 is \"Extremely helpful\"")

            Slider(value: $rating, in: 0...10, step: 1, minimumValueLabel: Text("0"), maximumValueLabel: Text("10")) {
            }
            HStack {
                Spacer()
                Text(String(Int(rating)))
                Spacer()
            }
            
            Text("Please let us know any other feedback you have here:")
            
            TextEditor(text: $feedback)
                .foregroundColor(.gray)
            
            Button("Submit Feedback", action: {
                submitFeedback()
            })

        }
        }
    }
    
    func submitFeedback() {
        isLoading = true
        
        let url = APIEndpoints.RATE_CALL
        
        let params = ["id" : callId, "rating" : String(Int(rating)), "feedback" : feedback]
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseJSON {response in
            
            switch(response.result) {
            case let .success(value):
                guard let json = value as? [String: Any] else {
                    return handleSubmitResponse(false, #line)
                }
                
                guard let status = json["status"] as? Bool else {
                    return handleSubmitResponse(false, #line)
                }
                
                return handleSubmitResponse(status, #line)
            case let .failure(error):
                debugPrint(error)
                
                return handleSubmitResponse(false, #line)
            }
        }
    }
    
    func handleSubmitResponse(_ status: Bool, _ lineNo: Int?) {
        if(status) {
            alert = Alert(title: Text("Call Rating Submitted"), message: Text("Your feedback has been submitted. Thank you."), dismissButton: .default(Text("Okay"), action: {
                self.presentationMode.wrappedValue.dismiss()
            }))
        } else {
            alert = Alert(title: Text("Error"), message: Text("There was an error submitting your feedback - please try again.\nIf this error persists, contact support with error code 8\(lineNo!)"), dismissButton: .default(Text("Okay"), action: {
                self.presentationMode.wrappedValue.dismiss()
            }))
        }
        
        isAlerting = true
        isLoading = false
    }
}
