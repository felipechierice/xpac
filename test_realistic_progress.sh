#!/bin/bash

# Test realistic progress animation
NC='\033[0m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'

test_realistic_progress() {
  local duration=20  # Test for 20 seconds
  local frame=0
  local start_time=$(date +%s)
  local estimated_duration=90  # Same as in xpac
  
  # Colors and characters
  local rgb_colors=(
    '\033[38;5;196m' '\033[38;5;202m' '\033[38;5;208m' '\033[38;5;214m'
    '\033[38;5;220m' '\033[38;5;226m' '\033[38;5;118m' '\033[38;5;82m'
    '\033[38;5;51m' '\033[38;5;45m' '\033[38;5;39m' '\033[38;5;99m'
    '\033[38;5;129m' '\033[38;5;165m' '\033[38;5;201m' '\033[38;5;197m'
  )
  
  local spinner_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  
  local messages=(
    "🔍 Discovering available mirrors"
    "🌐 Testing mirror connectivity" 
    "📡 Analyzing response times"
    "⚡ Measuring download speeds"
    "🏃 Racing mirrors for performance"
    "📊 Ranking by efficiency"
    "🎯 Selecting optimal mirrors"
    "💾 Optimizing mirrorlist"
    "🔄 Finalizing configuration"
  )
  
  echo "Testing realistic progress (watch for 20 seconds):"
  echo "Progress should go from 0% to about 22% (20s of 90s estimated)"
  echo
  
  local end_time=$((start_time + duration))
  while (( $(date +%s) < end_time )); do
    local current_time=$(date +%s)
    local elapsed_time=$((current_time - start_time))
    
    # Calculate realistic progress
    local progress=$((elapsed_time * 100 / estimated_duration))
    
    # Cap at 95%
    if (( progress > 95 )); then
      progress=95
    fi
    
    # Choose message based on progress
    local msg_index=0
    if (( progress >= 10 && progress < 25 )); then
      msg_index=1
    elif (( progress >= 25 && progress < 45 )); then
      msg_index=2
    elif (( progress >= 45 && progress < 65 )); then
      msg_index=3
    elif (( progress >= 65 && progress < 80 )); then
      msg_index=4
    elif (( progress >= 80 && progress < 90 )); then
      msg_index=5
    elif (( progress >= 90 && progress < 95 )); then
      msg_index=6
    elif (( progress >= 95 )); then
      msg_index=7
    fi
    
    # Display
    echo -ne "\r\033[K"
    echo -ne "${messages[$msg_index]} "
    
    local spinner_idx=$((frame % ${#spinner_chars[@]}))
    local color_idx=$((frame % ${#rgb_colors[@]}))
    echo -ne "${rgb_colors[$color_idx]}${spinner_chars[$spinner_idx]}${NC}"
    
    # Color coding based on progress
    if (( progress <= 30 )); then
      echo -ne " ${YELLOW}${progress}%${NC}"
    elif (( progress <= 70 )); then
      echo -ne " ${CYAN}${progress}%${NC}"
    else
      echo -ne " ${GREEN}${progress}%${NC}"
    fi
    
    frame=$((frame + 1))
    sleep 0.2
  done
  
  echo -ne "\r\033[K"
  echo "✅ Test completed! Progress went from 0% to $progress% in $duration seconds"
  echo "In real usage, it would continue to 100% when reflector finishes."
}

test_realistic_progress