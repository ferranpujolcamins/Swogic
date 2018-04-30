#!/bin/bash
set -ev
swift package update
swift package generate-xcodeproj --enable-code-coverage
# Set pipefail to get status code of xcodebuild if it fails
set -v -o pipefail
# Test
xcodebuild -enableCodeCoverage YES -project Swogic.xcodeproj -scheme Swogic-Package test | xcpretty
