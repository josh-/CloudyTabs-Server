import PackageDescription
let package = Package(
	name: "cloudytabs-server",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-SQLite.git", majorVersion: 3),
	]
)
