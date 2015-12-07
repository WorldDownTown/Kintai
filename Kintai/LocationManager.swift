//
//  LocationManager.swift
//  Kintai
//
//  Created by shoji on 2015/12/01.
//
//

import CoreLocation

class LocationManager: CLLocationManager {

    private static let sharedInstance = LocationManager()
    private let beaconIdentifier = ""
    private let uuidString = ""

    override required init() {
        super.init()

        allowsBackgroundLocationUpdates = true
        delegate = self
    }

    /**
     位置情報取得の許可を確認
     */
    static func requestAlwaysAuthorization() {
        sharedInstance.requestAlwaysAuthorization()
    }
}


// MARK: CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if state != .Inside {
            return
        }
        NotificationManager.postLocalNotificationIfNeeded(
            message: "出勤しますか？",
            category: NotificationManager.workCategoryIdentifier)
    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NotificationManager.postLocalNotificationIfNeeded(
            message: "出勤しますか？",
            category: NotificationManager.workCategoryIdentifier)
    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        NotificationManager.postLocalNotificationIfNeeded(
            message: "退勤しますか？",
            category: NotificationManager.homeCategoryIdentifier)
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError:\(error.localizedDescription)")
    }

    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Failed monitoring with error:\(error.localizedDescription)")
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            print("NotDetermined")
            manager.requestAlwaysAuthorization()
        case .Restricted:
            print("Restricted")
        case .Denied:
            print("Denied")
        case .AuthorizedAlways:
            print("AuthorizedAlways")
            startMonitoringWithManager(manager)
        case .AuthorizedWhenInUse:
            print("AuthorizedWhenInUse")
            startMonitoringWithManager(manager)
        }
    }

    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("Start monitoring for region")
        manager.requestStateForRegion(region)
    }
}


// MARK: - CLBeaconRegion

extension LocationManager {

    /**
     iBeacon検知開始

     - parameter manager: CLLocationManager
     */
    private func startMonitoringWithManager(manager: CLLocationManager) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) {
            return
        }

        guard let proximityUUID = NSUUID(UUIDString: uuidString) else {
            return
        }

        let beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, identifier: beaconIdentifier)
        beaconRegion.notifyEntryStateOnDisplay = true   // ディスプレイ表示中も通知する
        manager.startMonitoringForRegion(beaconRegion)
    }
}
