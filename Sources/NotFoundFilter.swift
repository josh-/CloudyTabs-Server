//
//  File.swift
//  cloudytabs-serverPackageDescription
//
//  Created by Josh Parnham on 31/1/18.
//

import PerfectHTTP

struct NotFoundFilter: HTTPResponseFilter {
    func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> Void) {
        callback(.continue)
    }
    func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> Void) {
        if case .notFound = response.status {
            response.bodyBytes.removeAll()
            response.setHeader(.contentType, value: "application/json")

            do {
                try response.setBody(json: ["error": "Route \(response.request.path) is not valid"])
            } catch {
                response.status = .internalServerError
                response.setBody(string: "Error handling request: \(error)")
            }

            response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
            callback(.done)
        } else {
            callback(.continue)
        }
    }
}
