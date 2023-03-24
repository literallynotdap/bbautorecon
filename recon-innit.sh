#!/usr/bin/env bash

# Define colors for output messages
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

sudo chown -R $USER:$USER /opt

# Check if Reconftw is installed
if [ ! -d "/opt/reconftw" ]; then
  echo "${YELLOW}Reconftw is not installed. Installing from Github...${NC}"
  sudo git clone https://github.com/six2dez/reconftw /opt/reconftw
  cd /opt/reconftw
  /opt/reconftw/install.sh
  chmod +x reconftw.sh
  echo "Reconftw installed successfully."
else
  echo -e "${GREEN}\nReconftw is already installed.${NC}"
fi

# Check if bbscope is installed
if ! command -v bbscope &> /dev/null
then
    # If bbscope is not installed, install it
    echo "${YELLOW}bbscope is not installed. Installing now...${NC}"
    GO111MODULE=on go install github.com/sw33tLie/bbscope@latest
else
  echo -e "${GREEN}bbscope is already installed.${NC}"

fi



# Prompt user for API token, username, and platform
echo ""
read -p "Enter your API token: " APITOKEN
echo ""
read -p "Enter your username: " USERNAME
echo ""
read -p "Enter the platform (h1, bc, immunefi, it, or ywh): " PLATFORM

# Prompt user to choose flags for the platform
case "$PLATFORM" in
  h1)
    echo -e "${BLUE}\n  Available flags:${NC} --active-only, --categories, --concurrency, --public-only, --pvtOnly\n    (e.g. --public-only --categories url or --pvtOnly --categories url)\n"
    read -p "Enter bbscope flags to use: " FLAGS
    echo -e "${GREEN}\nGetting scope w/ bbscope..."
    ;;
  bc)
    echo -e "${BLUE}\n  Available flags:${NC} --categories, --concurrency, --email, --password, --token"
    read -p "Enter the flags to use (e.g. --categories url): " FLAGS
    ;;
  ywh)
    echo -e "${BLUE}\n  Available flags:${NC} --categories, --token"
    read -p "Enter the flags to use (e.g. --categories url): " FLAGS
    ;;
  immunefi)
    echo -e "${BLUE}\n  Available flags:${NC} --categories, --concurrency"
    read -p "Enter the flags to use (e.g. --categories url): " FLAGS
    ;;
  *)
    echo -e "${RED}\n  Invalid platform${NC}"
    exit 1
    ;;
esac

# Define the command to run bbscope
BBSCOPE_CMD="bbscope $PLATFORM -t $APITOKEN -u $USERNAME $FLAGS"

# Run the bbscope command and extract the target scope
TARGET_SCOPE=$(eval $BBSCOPE_CMD 2>/dev/null | grep '^\*\.' | sed 's/^\*\.\(.*\)/\1/')

# Save the target scope to a file
echo "$TARGET_SCOPE" > "$OUTPUT_DIR/target_scope.txt"

cd /opt/reconftw

# Prompt user for command flags for running reconftw.sh
echo -e "${BLUE}\nRunning reconftw.sh...${NC}"
echo ""
echo -e "${YELLOW}Run reconftw help in /opt/reconftw directory to see all flags\n  (e.g. cd /opt/reconftw && ./reconftw.sh --help)${NC}"
echo ""
echo -e "${BLUE} Enter the command flags for reconftw.sh\n  ${NC}(e.g. -r for recon, -a for all: -a --deep for comprehensive scan)"
echo -e "   -> You don't need to provide the host list with -l, it's already provided...\n"
read -p  "ReconFTW Flags: " RECONFTW_FLAGS

# Run reconftw.sh with the specified flags
./reconftw.sh $RECONFTW_FLAGS -l "$OUTPUT_DIR/target_scope.txt" -a --deep 2>/dev/null
