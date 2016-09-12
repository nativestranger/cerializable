#!/usr/bin/env bash

set -e

rubies=("ruby-2.2.2" "ruby-2.3.1")
for i in "${rubies[@]}"
do
  echo "====================================================="
  echo "$i: Start Test"
  echo "====================================================="
  rvm $i exec bundle install
  rvm $i exec appraisal install
  rvm $i exec appraisal rake test
  echo "====================================================="
  echo "$i: End Test"
  echo "====================================================="
done
