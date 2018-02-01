//
//  JPTabsContainer.swift
//  cloudytabs-server
//
//  Created by Josh Parnham on 22/1/18.
//

import Foundation

protocol TabsContainer {
    static func canReadFile() -> Bool
    func deviceIDs() -> Array<String>
    func deviceName(for deviceID: String) -> String?
    func tabs(for deviceID: String) -> Array<Dictionary<String, String>>?
    func modificationDate() -> Date?
}
