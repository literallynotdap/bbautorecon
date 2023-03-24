#!/usr/bin/env bash

# Define colors
RED='\033[0;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Set default output file name
output_file=""

# Check for flags
while getopts "o:h" opt; do
  case ${opt} in
    o )
      output_file="$OPTARG"
      ;;
    h )
      echo "Usage: $0 [-o <output_file>] [-h]"
      echo ""
      echo "Options:"
      echo "-o: Save output to file with specified name."
      echo "-h: Display usage and help."
      exit 0
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done

# Find all nuclei_output directories and print the parent directory followed by that name
while IFS= read -r -d '' dir; do
  while IFS= read -r -d '' file; do
    output=$(cat "$file")
    color=$NC
    if echo "$output" | grep -q "\[critical\]"; then
      buffer_critical+="${RED}$file${NC}\n${RED}$output${NC}\n\n"
    elif echo "$output" | grep -q "\[high\]"; then
      buffer_high+="${RED}$file${NC}\n${RED}$output${NC}\n\n"
    elif echo "$output" | grep -q "\[medium\]"; then
      buffer_medium+="${ORANGE}$file${NC}\n${ORANGE}$output${NC}\n\n"
    elif echo "$output" | grep -q "\[low\]"; then
      buffer_low+="${YELLOW}$file${NC}\n${YELLOW}$output${NC}\n\n"
    elif echo "$file" | grep -q "\./"; then
      buffer_other+="${BLUE}$file${NC}\n\n"
    fi
  done < <(find "$dir" -type f -name '*.txt' -print0 2>/dev/null)
done < <(find . -name "nuclei_output" -type d -print0 2>/dev/null)
echo ""
echo -e "${GREEN}NUCLEI FINDINGS FROM RECONFTW${NC}\n"
echo -e "${RED}Critical findings:${NC}\n\n${buffer_critical}"
echo -e "${RED}High findings:${NC}\n\n${buffer_high}"
echo -e "${ORANGE}Medium findings:${NC}\n\n${buffer_medium}"
echo -e "${YELLOW}Low findings:${NC}\n\n${buffer_low}"
echo -e "${BLUE}Other findings:${NC}\n\n${buffer_other}"

# Save output to file if the -o flag was passed
if [[ -n "$output_file" ]]; then
  echo ""
  echo "Saving output to file: $output_file"
  echo ""
  echo -e "${RED}Critical findings:${NC}\n${buffer_critical}" > "$output_file"
  echo -e "${RED}High findings:${NC}\n${buffer_high}" >> "$output_file"
  echo -e "${ORANGE}Medium findings:${NC}\n${buffer_medium}" >> "$output_file"
  echo -e "${YELLOW}Low findings:${NC}\n${buffer_low}" >> "$output_file"
fi

# Display help if -h or --help flag is passed
if [[ $display_help == true ]]; then
  echo "Usage: $0 [-h|--help] [-o FILE]"
  echo "Searches for all 'nuclei_output' directories in the current directory and prints their contents sorted by severity level."
  echo ""
  echo "Options:"
  echo "  -h, --help  : Display this help message"
  echo "  -o FILE     : Save output to FILE"
fi
