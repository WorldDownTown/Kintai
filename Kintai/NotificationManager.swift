//
//  NotificationManager.swift
//  StartWork
//
//  Created by shoji on 2015/11/28.
//
//

import Foundation
import UIKit

struct NotificationManager {

    static let workCategoryIdentifier = "CATEGORY_WORK"
    static let homeCategoryIdentifier = "CATEGORY_HOME"
    static let workActionIdentifier = "ACTION_WORK"
    static let homeActionIdentifier = "ACTION_HOME"

    /**
     通知の許可を確認する
     */
    static func registerUserNotificationSettings() {
        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings(settings())
    }

    /**
     通知の許可を確認するときの設定を返す

     - returns: 通知の許可を確認するときの設定
     */
    private static func settings() -> UIUserNotificationSettings {
        let workAction = UIMutableUserNotificationAction()
        workAction.title = "出勤"
        workAction.identifier = workActionIdentifier
        workAction.activationMode = .Foreground
        workAction.destructive = false
        workAction.authenticationRequired = false

        let homeAction = UIMutableUserNotificationAction()
        homeAction.title = "退勤"
        homeAction.identifier = homeActionIdentifier
        workAction.activationMode = .Foreground
        homeAction.destructive = false
        homeAction.authenticationRequired = false

        let workCategory = UIMutableUserNotificationCategory()
        workCategory.identifier = workCategoryIdentifier
        workCategory.setActions([workAction], forContext: .Default)

        let homeCategory = UIMutableUserNotificationCategory()
        homeCategory.identifier = homeCategoryIdentifier
        homeCategory.setActions([homeAction], forContext: .Default)

        let categories: Set = [workCategory, homeCategory]
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: categories)

        return notificationSettings
    }

    /**
     前回の通知から一定時間以上経過していればローカル通知を飛ばす

     - parameter message:  表示メッセージ
     - parameter category: 通知のカテゴリ
     */
    static func postLocalNotificationIfNeeded(message message: String, category: String?) {
        if !shouldNotifyWithCategory(category) {
            return
        }

        print(message)

        let application = UIApplication.sharedApplication()
        application.cancelAllLocalNotifications()

        let notification = UILocalNotification()
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertAction = "OPEN"
        notification.category = category
        application.presentLocalNotificationNow(notification)
    }

    /**
     通知可否を返す

     - parameter category: 通知のカテゴリ

     - returns: true:通知可/false:通知不可
     */
    private static func shouldNotifyWithCategory(category: String?) -> Bool {
        guard let category = category else {
            return true
        }

        let defaults = NSUserDefaults.standardUserDefaults()
        let key = category
        let now = NSDate()
        let date = defaults.objectForKey(key)

        defaults.setObject(now, forKey: key)
        defaults.synchronize()

        if let date = date as? NSDate {
            let remainder = now.timeIntervalSinceDate(date)
            let threshold: NSTimeInterval = 60.0 * 60.0 * 1.0
            return (remainder > threshold)
        }

        return true
    }
}
