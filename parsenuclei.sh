#!/usr/bin/env bash

# Define colors
RED='\033[0;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Remove old report file and create a new one
> nuclei_scope_report.txt

# Find all nuclei_output directories and print the parent directory followed by that name
find . -name "nuclei_output" -type d -print0 2>/dev/null | while read -d $'\0' dir; do
  echo "Directory: $dir" >> nuclei_scope_report.txt
  echo "Directory: $dir"
  find "$dir" -type f -name '*.txt' -print0 2>/dev/null | while read -d $'\0' file; do
    output=$(cat "$file")
    echo "$output" >> nuclei_scope_report.txt
    color=$NC
    if echo "$output" | grep -q "\[critical\]\|\[high\]"; then
      color=$RED
    elif echo "$output" | grep -q "\[medium\]"; then
      color=$ORANGE
    elif echo "$output" | grep -q "\[low\]"; then
      color=$YELLOW
    fi
    echo -e "${color}$file${NC}"
    echo -e "${color}$output${NC}"
  done
done | grep -E "\[(low|medium|high|critical)\]" | while read line; do
  color=$NC
  if echo "$line" | grep -q "\[critical\]\|\[high\]"; then
    color=$RED
  elif echo "$line" | grep -q "\[medium\]"; then
    color=$ORANGE
  elif echo "$line" | grep -q "\[low\]"; then
    color=$YELLOW
  fi
  echo -e "${color}$line${NC}"
done
