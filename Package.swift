import PackageDescription

let package = Package(
    name: "CSH Drink",
    dependencies: [
	.Package(url: "https://github.com/harlanhaskins/Punctual.swift.git", majorVersion: 1)    
	]
)
