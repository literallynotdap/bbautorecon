#!/usr/bin/env bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Define default values for flags
output_file=""
verbose=false
get=""

# Define usage function
usage() {
  echo "Usage: $0 [-o output_file] [-v] [-g get]"
  echo "Options:"
  echo "  -o, --output FILE      Save output to FILE"
  echo "  -v, --verbose          Print verbose output"
  echo "  -g, --get PATTERN      Search output files for lines matching PATTERN"
  echo "  -h, --help             Display this help and exit"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -o|--output) output_file="$2"; shift ;;
    -v|--verbose) verbose=true ;;
    -g|--get) get="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
  esac
  shift
done

# Remove old report file and create a new one if output file specified
if [[ -n "$output_file" ]]; then
  > "$output_file"
fi

# Find all nuclei_output directories and print the parent directory followed by that name
while IFS= read -r -d '' dir; do
  if $verbose; then
    echo "Directory: $dir" >> "$output_file"
    echo "Directory: $dir"
  fi
  while IFS= read -r -d '' file; do
    output=$(cat "$file")
    if [[ -n "$get" ]]; then
      output=$(echo "$output" | grep -E "$get")
      if [[ -z "$output" ]]; then
        continue
      fi
    fi
    color=$NC
    if echo "$output" | grep -q "\[critical\]"; then
      buffer_critical+="${RED}$file${NC}\n${RED}$output${NC}\n\n"
    elif echo "$output" | grep -q "\[high\]"; then
      buffer_high+="${RED}$file${NC}\n${RED}$output${NC}\n\n"
    elif echo "$output" | grep -q "\[medium\]"; then
      buffer_medium+="${ORANGE}$file${NC}\n${ORANGE}$output${NC}\n\n"
    elif echo "$output" | grep -q "\[low\]"; then
      buffer_low+="${YELLOW}$file${NC}\n${YELLOW}$output${NC}\n\n"
    else
      buffer_other+="${GREEN}$file${NC}\n${GREEN}$output${NC}\n\n"
    fi
  done < <(find "$dir" -type f -name '*.txt' -print0 2>/dev/null)
done < <(find . -name "nuclei_output" -type d -print0 2>/dev/null)

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

# Print help message
function print_help {
  echo ""
  echo "Usage: ./nuclei-parser.sh [OPTIONS]"
  echo ""
  echo "OPTIONS:"
  echo "  -h, --help                  Display help message"
  echo "  -o, --output FILENAME       Save output to specified file"
  echo "  -t, --type TYPE             Filter findings by type (critical, high, medium, low)"
  echo "  -g, --get SEARCH_TERM       Only display lines that match on a grep regex of the search term in nuclei_output files"
  echo ""
}

# Handle command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help)
      print_help
      exit 0
      ;;
    -o|--output)
      output_file="$2"
      shift
      ;;
    -t|--type)
      case $2 in
        critical|high|medium|low)
          type_filter="$2"
          ;;
        *)
          echo "Invalid type filter: $2"
          exit 1
          ;;
      esac
      shift
      ;;
    -g|--get)
      search_term="$2"
      shift
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
  shift
done

# Filter findings by type if the -t flag was passed
if [[ -n "$type_filter" ]]; then
  if [[ "$type_filter" == "critical" ]]; then
    buffer_high=""
    buffer_medium=""
    buffer_low=""
  elif [[ "$type_filter" == "high" ]]; then
    buffer_critical=""
    buffer_medium=""
    buffer_low=""
  elif [[ "$type_filter" == "medium" ]]; then
    buffer_critical=""
    buffer_high=""
    buffer_low=""
  elif [[ "$type_filter" == "low" ]]; then
    buffer_critical=""
    buffer_high=""
    buffer_medium=""
  fi
fi

# Grep regex search in the nuclei_output files if the -g flag was passed
if [[ -n "$search_term" ]]; then
  buffer_critical=$(echo -e "$buffer_critical" | grep -E "$search_term")
  buffer_high=$(echo -e "$buffer_high" | grep -E "$search_term")
  buffer_medium=$(echo -e "$buffer_medium" | grep -E "$search_term")
  buffer_low=$(echo -e "$buffer_low" | grep -E "$search_term")
fi

# Print output to screen with color
if [[ -n "$get" ]]; then
  echo -e "${RED}Critical findings:${NC}\n${buffer_critical}" | grep -E "$get"
  echo -e "${RED}High findings:${NC}\n${buffer_high}" | grep -E "$get"
  echo -e "${ORANGE}Medium findings:${NC}\n${buffer_medium}" | grep -E "$get"
  echo -e "${YELLOW}Low findings:${NC}\n${buffer_low}" | grep -E "$get"
else
  echo -e "${RED}Critical findings:${NC}\n${buffer_critical}"
  echo -e "${RED}High findings:${NC}\n${buffer_high}"
  echo -e "${ORANGE}Medium findings:${NC}\n${buffer_medium}"
  echo -e "${YELLOW}Low findings:${NC}\n${buffer_low}"
fi

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
