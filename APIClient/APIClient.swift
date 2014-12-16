//
//  APIClient.swift
//  APIClient
//
//  Created by Hiroki Kato on 2014/12/15.
//  Copyright (c) 2014年 Hatena Inc. All rights reserved.
//

import Foundation

import AFNetworking
import Mantle

var dateTransformer: NSValueTransformer {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

    return MTLValueTransformer.reversibleTransformerWithForwardBlock({
        dateFormatter.dateFromString($0 as NSString)
    }, reverseBlock: {
        dateFormatter.stringFromDate($0 as NSDate)
    })
}

public class Status: MTLModel, MTLJSONSerializing {
    public var status: String?
    public var lastUpdated: NSDate?

    public class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "status" : "status",
            "lastUpdated" : "last_updated",
        ]
    }

    class func lastUpdatedJSONTransformer() -> NSValueTransformer {
        return dateTransformer
    }
}

public class Message: MTLModel, MTLJSONSerializing {
    public var status: String?
    public var body: String?
    public var createOn: NSDate?

    public class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "status" : "status",
            "body" : "body",
            "createOn" : "created_on",
        ]
    }

    class func createdOnJSONTransformer() -> NSValueTransformer {
        return dateTransformer
    }
}

public enum Response<T: MTLModel where T: MTLJSONSerializing> {
    case One(@autoclosure() -> T)
    case Many(@autoclosure() -> [T])
    case Error(NSError?)

    static func parse<T: MTLModel where T: MTLJSONSerializing>(JSON: AnyObject) -> Response<T> {
        var error: NSError?
        if let array = JSON as? [AnyObject] {
            if let xs = MTLJSONAdapter.modelsOfClass(T.self, fromJSONArray: array, error: &error) as? [T] {
                return .Many(xs)
            }
        } else if let object = JSON as? [NSObject: AnyObject] {
            if let x = MTLJSONAdapter.modelOfClass(T.self, fromJSONDictionary: object, error: &error) as? T {
                return .One(x)
            }
        }
        return .Error(error)
    }
}

enum Endpoint {
    case Status
    case LastMessage
    case Messages

    func request<T: MTLModel where T: MTLJSONSerializing>(manager: AFHTTPSessionManager, parameters: [String: String]?, handler:(response: Response<T>) -> Void) -> NSURLSessionDataTask {
        let success: ((NSURLSessionDataTask!, AnyObject!) -> Void) = {
            handler(response: Response<T>.parse($1))
        }
        let failure: ((NSURLSessionDataTask!, NSError!) -> Void) = {
            handler(response: Response.Error($1))
        }

        switch (self) {
        case .Status:
            return manager.GET("/api/status.json", parameters: parameters, success: success, failure: failure)
        case .LastMessage:
            return manager.GET("/api/last-message.json", parameters: parameters, success: success, failure: failure)
        case .Messages:
            return manager.GET("/api/messages.json", parameters: parameters, success: success, failure: failure)
        }
    }
}

public class APIClient {
    let manager = AFHTTPSessionManager(baseURL: NSURL(string: "https://status.github.com/")!)

    public func status(handler: (response: Response<Status>) -> Void) {
        Endpoint.Status.request(manager, parameters: nil, handler: handler)
    }

    public func lastMessage(handler: (response: Response<Message>) -> Void) {
        Endpoint.LastMessage.request(manager, parameters: nil, handler: handler)
    }

    public func messages(handler: (response: Response<Message>) -> Void) {
        Endpoint.Messages.request(manager, parameters: nil, handler: handler)
    }
}