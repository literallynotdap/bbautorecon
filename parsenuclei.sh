#!/usr/bin/env bash

# Define colors
RED='\033[0;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Remove old report file and create a new one
rm -f nuclei_scope_report.txt
touch nuclei_scope_report.txt

# Find all nuclei_output directories and print the parent directory followed by that name
find . -name "nuclei_output" -type d 2>/dev/null | while read dir; do
  echo "Directory: $dir" >> nuclei_scope_report.txt
  echo "Directory: $dir"
  find "$dir" -type f -name '*.txt' -print 2>/dev/null | while read file; do
    if grep -q "high.txt\|critical.txt" "$file"; then
      echo -e "\033[0;31m$file\033[0m" | tee -a nuclei_scope_report.txt
      echo "" | tee -a nuclei_scope_report.txt
      cat "$file" | tee -a nuclei_scope_report.txt
      echo "" | tee -a nuclei_scope_report.txt
    elif grep -q "medium.txt" "$file"; then
      echo -e "\033[0;33m$file\033[0m" | tee -a nuclei_scope_report.txt
      echo "" | tee -a nuclei_scope_report.txt
      cat "$file" | tee -a nuclei_scope_report.txt
      echo "" | tee -a nuclei_scope_report.txt
    elif grep -q "low.txt" "$file"; then
      echo -e "\033[1;33m$file\033[0m" | tee -a nuclei_scope_report.txt
      echo "" | tee -a nuclei_scope_report.txt
      cat "$file" | tee -a nuclei_scope_report.txt
      echo "" | tee -a nuclei_scope_report.txt
    else
      echo "$file" | tee -a nuclei_scope_report.txt
      cat "$file" | tee -a nuclei_scope_report.txt
    fi
  done
done | grep -E "\[(low|medium|high|critical)\]" | while read line; do
  if echo "$line" | grep -q "\[critical\]\|\[high\]"; then
    echo -e "${RED}$line${NC}"
  elif echo "$line" | grep -q "\[medium\]"; then
    echo -e "${ORANGE}$line${NC}"
  elif echo "$line" | grep -q "\[low\]"; then
    echo -e "${YELLOW}$line${NC}"
  fi
done
