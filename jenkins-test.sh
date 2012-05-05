#!/bin/bash

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# The location of RVM.
RVM_PATH="$HOME/.rvm/scripts/rvm"

if [ ! -f $RVM_PATH ]; then
  echo "RVM not found: $RVM_PATH"
  exit 1
fi

# Source RVM so .rvmrc files will work.
source $RVM_PATH

# Source the .rvmrc file.
[[ -s ".rvmrc" ]] && source .rvmrc

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

# Install any gems the tests may require.
bundle

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------

# Run the tests.
rake ci:setup:testunit test
