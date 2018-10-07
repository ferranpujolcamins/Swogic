#!/bin/bash
set -ev
# Generate cobertura coverage info
slather coverage --verbose --input-format profdata -x --scheme "Swogic-Package" Swogic.xcodeproj
# Send coverage info to codeclimate
./cc-test-reporter after-build --exit-code $TRAVIS_TEST_RESULT
