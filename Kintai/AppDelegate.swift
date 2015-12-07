//
//  AppDelegate.swift
//  Kintai
//
//  Created by shoji on 2015/11/29.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        NotificationManager.registerUserNotificationSettings()

        LocationManager.requestAlwaysAuthorization()

        return true
    }
}
