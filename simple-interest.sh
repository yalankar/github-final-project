#!/usr/bin/env bash
# simple-interest.sh
# Calculate Simple Interest based on user input.
# Formula: SI = (P * R * T) / 100

set -euo pipefail

# Colors for messages (optional)
GREEN="[0;32m"; RED="[0;31m"; YELLOW="[1;33m"; NC="[0m"

# Ensure bc is available for decimal arithmetic
if ! command -v bc >/dev/null 2>&1; then
  echo -e "${RED}Error:${NC} 'bc' is required but not installed. Please install bc and retry." >&2
  exit 1
fi

read -r -p "Enter Principal (P): " P
read -r -p "Enter Rate of Interest per annum (%) (R): " R
read -r -p "Enter Time period in years (T): " T

# Basic validation: non-empty, numeric (allow decimals)
validate_num() {
  # Accept integers or decimals, optionally with leading + or - (but we will reject negative later)
  [[ $1 =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]]
}

if [[ -z ${P} || -z ${R} || -z ${T} ]]; then
  echo -e "${RED}Error:${NC} All inputs (P, R, T) are required." >&2
  exit 1
fi

if ! validate_num "$P" || ! validate_num "$R" || ! validate_num "$T"; then
  echo -e "${RED}Error:${NC} Inputs must be numeric (you can use decimals)." >&2
  exit 1
fi

# No negatives for these financial inputs
for v in P R T; do
  val=${!v}
  # Use bc to compare decimal numbers reliably
  if [[ $(echo "$val < 0" | bc -l) -eq 1 ]]; then
    echo -e "${RED}Error:${NC} $v must not be negative." >&2
    exit 1
  fi
done

# Compute Simple Interest and Total Amount using bc (scale controls decimal places)
SCALE=2
SI=$(echo "scale=$SCALE; ($P * $R * $T) / 100" | bc -l)
A=$(echo "scale=$SCALE; $P + $SI" | bc -l)

# Pretty output
printf "
${GREEN}Results${NC}
"
printf "---------------------------
"
printf "Principal (P):           %s
" "$P"
printf "Rate (R):                %s %%
" "$R"
printf "Time (T):                %s years
" "$T"
printf "Simple Interest (SI):    %s
" "$SI"
printf "Total Amount (A = P+SI): %s
" "$A"
printf "---------------------------

"

# Tip on time units
echo -e "${YELLOW}Tip:${NC} If your time is in months, divide by 12 (e.g., 6 months = 0.5 years)."
