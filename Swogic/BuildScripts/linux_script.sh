#!/bin/bash
set -ev
swift package update
swift build
swift test
