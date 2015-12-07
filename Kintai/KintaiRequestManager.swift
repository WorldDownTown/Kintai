//
//  KintaiRequestManager.swift
//  Kintai
//
//  Created by shoji on 2015/12/02.
//  Copyright © 2015年 vasily.jp. All rights reserved.
//

import Foundation
import Ji

class KintaiRequestManager: NSObject {

    private enum SubmitType { case Work, Home }

    private static var sharedInstance = KintaiRequestManager()
    private var submitType: SubmitType = .Work
    private var dateString: String {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.systemTimeZone()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let now = NSDate()
        let timeInterval = now.timeIntervalSince1970
        let intMillSecond = Int(floor((timeInterval - floor(timeInterval)) * 1000.0))
        formatter.dateFormat = "yyyy/MM/dd H:m:s:\(intMillSecond)"
        return formatter.stringFromDate(now)
    }

    /**
     出退勤ごとのトップページリクエスト

     - parameter identifier: 通知ID
     */
    static func requestWithIdentifier(identifier: String?) {
        if identifier == NotificationManager.homeActionIdentifier {
            sharedInstance.submitType = .Work
            sharedInstance.requestTopPage()
        } else if identifier == NotificationManager.workActionIdentifier {
            sharedInstance.submitType = .Home
            sharedInstance.requestTopPage()
        }
    }

    /**
     勤怠トップページリクエスト
     */
    private func requestTopPage() {
        let urlString = ""
        let encodedUrlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: encodedUrlString)!
        let request = NSURLRequest(URL: url)

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTaskWithRequest(request)
        task.resume()
    }

    /**
     POSTリクエスト

     - parameter urlString: URL文字列
     - parameter params:    パラメータ
     */
    private func requestPost(urlString: String, params: [String: String]) {
        let urlEncode: (String -> String) = { (string: String) in
            if let encodedString = string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                return encodedString
            } else {
                return string
            }
        }
        let pairs = params.flatMap { "\($0)=\(urlEncode($1))" }
        let bodyString = pairs.joinWithSeparator("&")
        let body = bodyString.dataUsingEncoding(NSShiftJISStringEncoding)
        let encodedUrlString = urlEncode(urlString)
        let url = NSURL(string: encodedUrlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = body

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        let session = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request)
        task.resume()
    }
}


extension KintaiRequestManager: NSURLSessionDelegate {

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        guard let ji = Ji(data: NSData(contentsOfURL: location), encoding: NSShiftJISStringEncoding, isXML: false) else {
            return
        }

        guard let formNode = ji.xPath("//form")?.first else {
            return
        }

        guard let action = formNode.attributes["action"] else {
            return
        }

        guard let inputNodes1 = ji.xPath("//input[@type='hidden']") else {
            return
        }

        guard let inputNodes2 = ji.xPath("//input[@type='HIDDEN']") else {
            return
        }
        let inputNodes = inputNodes1 + inputNodes2

        let urlString = "" + action

        var params: [String: String] = [:]
        params["EZZdupSndFlag"] = "false"
        params["EZZsndDateTime"] = dateString
        params["EZZUSCD"] = ""
        params["EZZPWCD"] = ""

        for node in inputNodes {
            if let name = node.attributes["name"] {
                if let value = node.attributes["value"] {
                    params[name] = value
                } else {
                    params[name] = ""
                }
            }
        }

        if submitType == .Work {
            params["&USER2"] = "出勤"
        } else if submitType == .Home {
            params["&USER3"] = "退勤"
        }

        requestPost(urlString, params: params)
    }
}
