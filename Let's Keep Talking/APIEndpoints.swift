//
//  APIEndpoints.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 21/09/2020.
//

public class APIEndpoints {
    private static var ROOT = "https://waaur9gdvj.execute-api.eu-west-2.amazonaws.com/Dev/"
    private static var CLIENT_ROOT = ROOT + "clients/"
    private static var CALLER_ROOT = ROOT + "callers/"
    private static var AVAIL_ROOT = CALLER_ROOT + "availability/"
    
    public static var CREATE_ACC = CLIENT_ROOT + "create-acct/"
    public static var CLIENT_LOGIN = CLIENT_ROOT + "login/"
    public static var GET_CALLERS = CLIENT_ROOT + "get-callers/"
    public static var GET_APPOINTMENTS = CLIENT_ROOT + "get-appointments/"
    public static var BOOK_CALL = CLIENT_ROOT + "book/"
    public static var CANCEL_CALL = CLIENT_ROOT + "cancel/"
    public static var GET_CLIENT_CALLS = CLIENT_ROOT + "get-calls/"
    
    public static var CALLER_LOGIN = CALLER_ROOT + "login/"
    public static var GET_CALLER_CALLS = CALLER_ROOT + "get-calls/"
    public static var GET_AVAILABILITY = AVAIL_ROOT + "get/"
    public static var SET_AVAILABILITY = AVAIL_ROOT + "set/"
    public static var ADD_CALL_LENGTH = CALLER_ROOT + "add-call-length/"
}
