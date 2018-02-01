//
//  JPCloudTabsDBReader.swift
//  cloudytabs-server
//
//  Created by Josh Parnham on 27/1/18.
//

import Foundation
import PerfectSQLite

class SyncedPreferencesReader: TabsContainer {

    class func canReadFile() -> Bool {
        if let dictionary = self.syncedPreferenceDictionary() {
            if let values = dictionary["values"] {
                if Array<String>((values as! Dictionary<String, String>).keys).count > 0 {
                    return true
                }
            }
        }

        return false
    }

    class func syncedPreferencesDirectory() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        if let firstPath = paths.first {
            return (firstPath as NSString).appendingPathComponent("SyncedPreferences")
        }
        return nil
    }

    class func syncedPreferenceDictionary() -> Dictionary<String, AnyObject>? {
        if let filePath = self.filePath() {
            return NSDictionary(contentsOfFile: filePath) as? Dictionary<String, AnyObject>
        }
        return Dictionary()
    }

    class func filePath() -> String? {
        guard let syncedPreferencesDirectory = self.syncedPreferencesDirectory() else {
            return nil
        }
        return (syncedPreferencesDirectory as NSString).appendingPathComponent("com.apple.Safari.plist")
    }

    func deviceIDs() -> Array<String> {
        var deviceIDs = Array<String>()

        guard let dictionary = type(of: self).syncedPreferenceDictionary() else {
            return deviceIDs
        }

        let values = (dictionary as NSDictionary).value(forKey: "values")
        (values as! Dictionary<String, AnyObject>).keys.forEach { (deviceID) in
            let lastModified = (values as! NSDictionary).value(forKeyPath: "\(deviceID).value.LastModified")

            if (lastModified as! NSDate).timeIntervalSinceNow < 604800 {
                deviceIDs.append(deviceID)
            }
        }

        return deviceIDs
    }

    func deviceName(for deviceID: String) -> String? {
        if let dictionary = type(of: self).syncedPreferenceDictionary() {
            if let deviceName = (dictionary as NSDictionary).value(forKeyPath: "values.\(deviceID).value.DeviceName") {
                return String(describing: deviceName)
            }
        }
        return nil
    }

    func tabs(for deviceID: String) -> Array<Dictionary<String, String>>? {
        if let dictionary = type(of: self).syncedPreferenceDictionary() {
            if let tabs = (dictionary as NSDictionary).value(forKeyPath: "values.\(deviceID).value.Tabs") {

                var tabArray: Array<Dictionary<String, String>> = []
                for tab in (tabs as! Array<Dictionary<String, String>>) {
                    if let url = tab["URL"] {
                        if let title = tab["Title"] {
                            tabArray.append(["url": url, "title": title])
                        } else {
                            tabArray.append(["url": url, "title": url])
                        }

                    }
                }
                return tabArray
            }
        }
        return nil
    }

    func modificationDate() -> Date? {
        guard let syncedPreferencesDirectory = type(of: self).syncedPreferencesDirectory() else {
            return nil
        }

        let preferencesURL = NSURL(string: syncedPreferencesDirectory)
        var modificationDate: AnyObject?

        try? preferencesURL?.getResourceValue(&modificationDate, forKey: .contentModificationDateKey)
        return modificationDate as? Date
    }
}
