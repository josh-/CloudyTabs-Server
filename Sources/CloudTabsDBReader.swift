//
//  JPSyncedPreferencesReader.swift
//  cloudytabs-server
//
//  Created by Josh Parnham on 22/1/18.
//

import Foundation
import PerfectSQLite

class CloudTabsDBReader: TabsContainer {

    static func canReadFile() -> Bool {
        var tableExists: Bool = false

        guard let filePath = self.filePath() else {
            return tableExists
        }

        do {
            let sqlite = try? SQLite(filePath)
            defer {
                sqlite?.close()
            }

            do {
                let statement = "SELECT name FROM sqlite_master WHERE type='table' AND name='cloud_tabs'"
                try sqlite?.forEachRow(statement: statement, handleRow: {(statement: SQLiteStmt, _: Int) -> Void in
                    if statement.columnText(position: 0) == "cloud_tabs" {
                        tableExists = true
                    }
                })
            } catch {
                tableExists = false
            }
            return tableExists
        }
    }

    class func safariLibraryDirectory() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        if let firstPath = paths.first {
            return (firstPath as NSString).appendingPathComponent("Safari")
        }
        return nil
    }

    class func filePath() -> String? {
        guard let safariLibraryDirectory = self.safariLibraryDirectory() else {
            return nil
        }
        return (safariLibraryDirectory as NSString).appendingPathComponent("CloudTabs.db")
    }

    func deviceIDs() -> Array<String> {
        var deviceIDs: [String] = Array()

        guard let filePath = type(of: self).filePath() else {
            return deviceIDs
        }

        let sqlite = try? SQLite(filePath)
        defer {
            sqlite?.close()
        }

        do {
            let statement = "SELECT device_uuid from cloud_tab_devices GROUP BY device_uuid"
            try? sqlite?.forEachRow(statement: statement, handleRow: { (statement: SQLiteStmt, _: Int) in
                    deviceIDs.append(statement.columnText(position: 0))
            })
        }
        return deviceIDs
    }

    func deviceName(for deviceID: String) -> String? {
        guard let filePath = type(of: self).filePath() else {
            return nil
        }

        let sqlite = try? SQLite(filePath)
        defer {
            sqlite?.close()
        }

        var name: String? = nil

        do {
            let statement = "SELECT device_name from cloud_tab_devices WHERE device_uuid = :1"
            try sqlite?.forEachRow(statement: statement, doBindings: { (statement: SQLiteStmt) -> Void in
                try statement.bind(position: 1, deviceID)
            }, handleRow: {(statement: SQLiteStmt, _: Int) -> Void in
                name = statement.columnText(position: 0)
            })
        } catch {
            return nil
        }
        return name
    }

    func tabs(for deviceID: String) -> Array<Dictionary<String, String>>? {
        guard let filePath = type(of: self).filePath() else {
            return nil
        }

        var tabs: [Dictionary<String, String>] = Array()

        let sqlite = try? SQLite(filePath)
        defer {
            sqlite?.close()
        }

        do {
            let statement = "SELECT title, url from cloud_tabs WHERE device_uuid = :1"
            try sqlite?.forEachRow(statement: statement, doBindings: { (statement: SQLiteStmt) -> Void in
                try statement.bind(position: 1, deviceID)
            }, handleRow: {(statement: SQLiteStmt, _: Int) -> Void in
                let URL = statement.columnText(position: 0)
                let title = statement.columnText(position: 1)
                tabs.append(["url": URL, "title": title])
            })
        } catch {
            return tabs
        }
        return tabs
    }

    func modificationDate() -> Date? {
        guard let safariLibraryDirectory = type(of: self).safariLibraryDirectory() else {
            return nil
        }

        let preferencesURL = NSURL(string: safariLibraryDirectory)
        var modificationDate: AnyObject?

        try? preferencesURL?.getResourceValue(&modificationDate, forKey: .contentModificationDateKey)
        return modificationDate as? Date
    }
}
