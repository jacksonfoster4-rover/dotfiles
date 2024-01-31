#!/bin/bash

git add -A

# Get the list of changed files from git
changed_py_files=$(git diff --name-only HEAD | grep 'aplaceforrover/.*tests/.*\.py$')

# Iterate over the list of changed files
while IFS= read -r file; do
    new_path=${file#aplaceforrover/}

    # Replace slashes with periods in the file name
    new_name=$(echo "$new_path" | tr '/' '.')
    
    # remove .py
    new_name_without_py=$(echo "$new_name" | sed 's/\.py$//')

    # Echo the new name
    t "$new_name_without_py"
done <<< "$changed_py_files" 

# Get the list of changed files from git
changed_js_files=$(git diff --name-only HEAD | grep 'frontend/.*\.test\..*')

# Iterate over the list of changed files
while IFS= read -r file; do
    # Echo the new name
    fe jest "$file"
done <<< "$changed_js_files" 

git reset -q
