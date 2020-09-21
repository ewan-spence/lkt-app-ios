//
//  APIEndpoints.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 21/09/2020.
//

public class APIEndpoints {
    private static var ROOT = "https://waaur9gdvj.execute-api.eu-west-2.amazonaws.com/Dev/"
    private static var CLIENT_ROOT = ROOT + "clients/"
    public static var CREATE_ACC = CLIENT_ROOT + "create-acct/"
    
    public static var CLIENT_LOGIN = CLIENT_ROOT + "login/"
    private static var CALLER_ROOT = ROOT + "callers/"
    public static var BOOK_CALL = CLIENT_ROOT + "book/"
    public static var CALLER_LOGIN = CALLER_ROOT + "login/"
    private static var AVAIL_ROOT = CALLER_ROOT + "availability/"
    public static var GET_AVAILABILITY = AVAIL_ROOT + "get/"
    public static var SET_AVAILABILITY = AVAIL_ROOT + "set/"
}
