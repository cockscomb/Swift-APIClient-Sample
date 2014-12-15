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

enum Endpoint {
    case Status
    case LastMessage
    case Messages

    func request<T: MTLModel where T: MTLJSONSerializing>(manager: AFHTTPSessionManager, parameters: [String: String]?, handler: ((response: T?, error: NSError?) -> Void)) -> NSURLSessionDataTask {
        let success: ((NSURLSessionDataTask!, AnyObject!) -> Void) = {
            var error: NSError?
            var response: T? = nil

            if let dictonary = $1 as? [NSObject : AnyObject] {
                response = MTLJSONAdapter.modelOfClass(T.self, fromJSONDictionary: dictonary, error: &error) as? T
            }

            handler(response: response, error: error)
        }
        let failure: ((NSURLSessionDataTask!, NSError!) -> Void) = {
            handler(response: nil, error: $1)
        }
        return request(manager, parameters: parameters, success: success, failure: failure)
    }

    func request<T: MTLModel where T: MTLJSONSerializing>(manager: AFHTTPSessionManager, parameters: [String: String]?, handler: ((response: [T]?, error: NSError?) -> Void)) -> NSURLSessionDataTask {
        let success: ((NSURLSessionDataTask!, AnyObject!) -> Void) = {
            var error: NSError?
            var response: [T]? = nil

            if let array = $1 as? [AnyObject] {
                response = MTLJSONAdapter.modelsOfClass(T.self, fromJSONArray: array, error: &error) as? [T]
            }

            handler(response: response, error: error)
        }
        let failure: ((NSURLSessionDataTask!, NSError!) -> Void) = {
            handler(response: nil, error: $1)
        }
        return request(manager, parameters: parameters, success: success, failure: failure)
    }

    private func request(manager: AFHTTPSessionManager, parameters: [String: String]?, success: ((NSURLSessionDataTask!, AnyObject!) -> Void), failure: ((NSURLSessionDataTask!, NSError!) -> Void)) -> NSURLSessionDataTask {

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

    public func status(handler: ((response: Status?, error: NSError?) -> Void)) {
        Endpoint.Status.request(manager, parameters: nil, handler: handler)
    }

    public func lastMessage(handler: ((response: Message?, error: NSError?) -> Void)) {
        Endpoint.LastMessage.request(manager, parameters: nil, handler: handler)
    }

    public func messages(handler: ((response: [Message]?, error: NSError?) -> Void)) {
        Endpoint.Messages.request(manager, parameters: nil, handler: handler)
    }
}