//
//  main.swift
//  cloudytabs-server
//
//  Created by Josh Parnham on 22/1/18.
//  Adapted from the Perfect.org open source project
//  Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
//  Licensed under Apache License v2.0
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let cloudTabsReader: AnyObject & TabsContainer
if CloudTabsDBReader.canReadFile() {
    cloudTabsReader = CloudTabsDBReader()
} else if SyncedPreferencesReader.canReadFile() {
    cloudTabsReader = SyncedPreferencesReader()
} else {
    fatalError("No supported cloud tab readers are available – have you signed into iCloud and enabled Safari syncing?")
}

func devicesHandler(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")

    var deviceMapping: Array<Dictionary<String, String>> = Array()
    cloudTabsReader.deviceIDs().forEach { (deviceId) in
        if let deviceName = cloudTabsReader.deviceName(for: deviceId) {
            deviceMapping.append(["deviceID": deviceId, "name": deviceName])
        }
    }

    do {
        try response.setBody(json: deviceMapping)
    } catch {
        response.status = .internalServerError
        response.setBody(string: "Error handling request: \(error)")
    }
    response.completed()
}

func tabsHandler(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")

    if let deviceID = request.urlVariables["deviceID"] {
        let tabs = cloudTabsReader.tabs(for: deviceID)

        do {
            try response.setBody(json: tabs)
        } catch {
            response.status = .internalServerError
            response.setBody(string: "Error handling request: \(error)")
        }
    }
    response.completed()
}

var routes = Routes()
routes.add(method: .get, uri: "/devices", handler: devicesHandler)
routes.add(method: .get, uri: "/tabs/{deviceID}", handler: tabsHandler)

let responseFilters: [(HTTPResponseFilter, HTTPFilterPriority)] = [
    (try! PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high),
    (NotFoundFilter(), HTTPFilterPriority.high),
]

do {
    let server = HTTPServer()
    server.setResponseFilters(responseFilters)
    if let localPortValue = ProcessInfo.processInfo.environment["CLOUDYTABS_LOCAL_PORT"], let localPort = UInt16(localPortValue) {
        server.serverPort = localPort
    } else {
        server.serverPort = 8181
    }
    server.addRoutes(routes)
    try server.start()
} catch {
	fatalError("\(error)")
}
