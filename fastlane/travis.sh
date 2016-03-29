#!/bin/sh

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]] || [[ "$TRAVIS_BRANCH" == "master" ]]; then
  fastlane test
  exit $?
fi
