#!/bin/bash

alias start_up="m dev_create_facilities_fixture_data && dc up -d"
alias start_rxn="(cd src/frontend/reactNativeApp && yarn start)"
alias mypy="dc run --workdir /web --rm --no-deps web mypy --show-error-codes"
