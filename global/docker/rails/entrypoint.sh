#!/bin/sh -ex

if [ "$RAILS_ENV" = "development" ]; then
  bundle config set without 'test'
  bundle install
fi

exec "$@"
