#!/bin/bash

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------

RBENV_PATH="$HOME/.rbenv"

if [ ! -d $RBENV_PATH ]; then
  echo "rbenv path not found: $RBENV_PATH"
  exit 1
fi

# Add to PATH environment variable so rbenv command-line utility is available.
export PATH="$RBENV_PATH/bin:$PATH"

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# Enable rbenv shims and autocompletion.
eval "$(rbenv init -)"

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

# For debugging purposes, output the current version of Ruby, and from where
# it was set.
rbenv version
# Install any gems the tests may require.
bundle

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------

# Run the tests.
bundle exec rake ci:setup:testunit test
