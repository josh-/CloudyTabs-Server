# CloudyTabs-Server

A compliment to [CloudyTabs](https://github.com/josh-/CloudyTabs), `CloudyTabs-Server` is a simple API that exposes a user's iCloud tabs through a JSON API.

It was inspired by [@erikcw](https://github.com/erikcw) who discussed this idea in [this comment](https://github.com/josh-/CloudyTabs/issues/41#issuecomment-351824882):

> One possible solution would be to expose a simple local API (maybe a small webserver serving JSON?) that external tools can access to get at the data. It would be trivial to write plugins for tools like Alfred and Quicksilver to access and filter that data. Not to mention all the other extensibility benefits that come from being able to programmatically access the data.

## Installation

TODO

## Usage

TODO

### API Documentation

#### List all devices
Request:

`GET` `/devices`

Response:

`200`
```json
[
    {
        "name": "Josh’s MacBook Pro",
        "deviceID": "<DEVICE_ID>"
    },
    {
        "name": "Josh’s iPhone X",
        "deviceID": "<DEVICE_ID>"
    }
]
```

#### List tabs for device
Request:

`GET` `/tabs/{deviceID}`

Response:

`200`
```json
[
    {
        "title": "https://github.com/josh-/CloudyTabs/pulls",
        "url": "Pull Requests · josh-/CloudyTabs"
    },
    {
        "title": "https://github.com/josh-/CloudyTabs",
        "url": "josh-/CloudyTabs: CloudyTabs is a simple menu bar application that lists your iCloud Tabs."
    }
]
```

## Requirements

- masOS 10.10 or later
- An active iCloud account