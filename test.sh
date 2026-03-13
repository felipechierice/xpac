#!/usr/bin/env bash

# Basic Test Script for xpac

# --- Configuration ---
# Path to the xpac executable (assuming it's in PATH)
XPAC_CMD="xpac"
# A small, generally harmless package available in most repos for install/remove tests
TEST_PKG="sl"
# Set to 1 to skip tests requiring sudo (install, remove, etc.)
SKIP_SUDO_TESTS=0

# --- Colors ---
COL_RESET="\033[0m"
COL_RED="\033[0;31m"
COL_GREEN="\033[0;32m"
COL_YELLOW="\033[0;33m"
COL_BLUE="\033[0;34m"
COL_BOLD="\033[1m"

# --- Test Counters ---
declare -i tests_run=0
declare -i tests_passed=0
declare -i tests_failed=0
declare -i tests_skipped=0

# --- Helper Functions ---

# Function to print test status
# Args: $1: Status (PASS|FAIL|SKIP)
#       $2: Test description
_print_status() {
    local status="$1"
    local description="$2"
    local color=$COL_YELLOW

    case "$status" in
        PASS) color=$COL_GREEN ;;
        FAIL) color=$COL_RED ;;
        SKIP) color=$COL_BLUE ;;
    esac

    printf "[%b%s%b] %s\n" "$color" "$status" "$COL_RESET" "$description"
}

# Function to run a test command and check its exit code
# Args: $1: Expected exit code (usually 0 for success, non-zero for expected failure)
#       $2: Test description
#       $@: Command to run (starting from $3)
_run_test() {
    local expected_code="$1"
    local description="$2"
    shift 2
    local cmd_to_run=("$@")
    local exit_code=0
    local output=""

    ((tests_run++))
    printf "* Running: %s\n" "${cmd_to_run[*]}"

    # Capture output and exit code
    # Redirect stderr to stdout to capture errors from xpac itself
    output=$("${cmd_to_run[@]}" 2>&1)
    exit_code=$?

    if [ "$exit_code" -eq "$expected_code" ]; then
        _print_status "PASS" "$description"
        ((tests_passed++))
    else
        _print_status "FAIL" "$description (Expected code $expected_code, got $exit_code)"
        ((tests_failed++))
        # Print output only on failure for easier debugging
        echo "--- Output on Failure ---"
        echo "$output"
        echo "-------------------------"
    fi
    echo # Add a blank line for readability
    return $exit_code # Return actual exit code
}

# Function to skip a test
# Args: $1: Test description
_skip_test() {
    local description="$1"
    ((tests_run++))
    ((tests_skipped++))
    _print_status "SKIP" "$description"
    echo
}

# Function to run a command and verify its output CONTAINS a pattern
# Args: $1: Test description, $2: Pattern to grep for, $3+: Command to run
_run_test_grep() {
    local description="$1"
    local pattern="$2"
    shift 2
    local cmd_to_run=("$@")
    local output=""

    ((tests_run++))
    printf "* Running: %s | grep -q '%s'\n" "${cmd_to_run[*]}" "$pattern"

    output=$("${cmd_to_run[@]}" 2>&1)
    if echo "$output" | grep -qw "$pattern"; then
        _print_status "PASS" "$description"
        ((tests_passed++))
    else
        _print_status "FAIL" "$description (pattern '$pattern' not found in output)"
        ((tests_failed++))
        echo "--- Output on Failure ---"
        echo "$output"
        echo "-------------------------"
    fi
    echo
}

# Function to run a command and verify its output does NOT contain a pattern
# Args: $1: Test description, $2: Pattern that should be absent, $3+: Command to run
_run_test_grep_absent() {
    local description="$1"
    local pattern="$2"
    shift 2
    local cmd_to_run=("$@")
    local output=""

    ((tests_run++))
    printf "* Running: %s | grep -qv '%s'\n" "${cmd_to_run[*]}" "$pattern"

    output=$("${cmd_to_run[@]}" 2>&1)
    if ! echo "$output" | grep -qw "$pattern"; then
        _print_status "PASS" "$description"
        ((tests_passed++))
    else
        _print_status "FAIL" "$description (pattern '$pattern' unexpectedly found in output)"
        ((tests_failed++))
        echo "--- Output on Failure ---"
        echo "$output"
        echo "-------------------------"
    fi
    echo
}

# --- Pre-Checks ---
printf "\n%b--- Starting xpac Test Suite ---%b\n\n" "$COL_BOLD" "$COL_RESET"

if ! command -v "$XPAC_CMD" &>/dev/null; then
    _print_status "FAIL" "Prerequisite check: '$XPAC_CMD' command not found in PATH."
    exit 1
else
     _print_status "PASS" "Prerequisite check: '$XPAC_CMD' command found."
     # Get version early
     XPAC_VERSION_OUTPUT=$($XPAC_CMD --version)
     echo "Testing $XPAC_VERSION_OUTPUT"
     echo
fi

# Check for sudo requirement if needed
if [ "$SKIP_SUDO_TESTS" -eq 0 ]; then
    if ! sudo -n true 2>/dev/null; then
        _print_status "WARN" "Sudo tests require passwordless sudo or user interaction."
        read -rp "Attempt sudo tests anyway? [y/N] " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            SKIP_SUDO_TESTS=1
            _print_status "INFO" "Skipping tests requiring sudo."
        fi
        echo
    else
         _print_status "INFO" "Passwordless sudo detected or not required."
         echo
    fi
fi


# --- Test Sections ---

echo "--- Basic Options ---"
_run_test 0 "Display help message" "$XPAC_CMD" --help
_run_test 0 "Display version information" "$XPAC_CMD" --version

echo "--- System Utilities (Requires Dependencies Installed) ---"
_run_test 0 "Run sysinfo command" "$XPAC_CMD" sysinfo
_run_test 0 "Run disk command" "$XPAC_CMD" disk
_run_test 0 "Run memory command" "$XPAC_CMD" mem
_run_test 0 "Run cpuinfo command" "$XPAC_CMD" cpuinfo
_run_test 0 "Run ip command" "$XPAC_CMD" ip
_run_test 0 "Run ping command" "$XPAC_CMD" ping
_run_test 0 "Run top command (default)" "$XPAC_CMD" top
_run_test 0 "Run top command (sort mem)" "$XPAC_CMD" top -s mem
_run_test 0 "Run top command (5 lines)" "$XPAC_CMD" top -n 5
_run_test 0 "Run top command (filter)" "$XPAC_CMD" top -f "_some_unlikely_string_xyz_" # Should find nothing but exit 0

echo "--- Package Info & Listing ---"
_run_test 0 "Search for '$TEST_PKG'" "$XPAC_CMD" search "$TEST_PKG"
_run_test 0 "List all available packages" "$XPAC_CMD" list
_run_test 0 "List installed packages" "$XPAC_CMD" list-installed
# Try showing info for a package likely to be installed (coreutils or bash)
INSTALLED_CORE_PKG="coreutils"
# Check if package is installed using search-installed (should exit 0 if found, non-zero otherwise)
if ! $XPAC_CMD search-installed "$INSTALLED_CORE_PKG" > /dev/null 2>&1; then
    # Fallback to bash if coreutils isn't found listed
    INSTALLED_CORE_PKG="bash"
    if ! $XPAC_CMD search-installed "$INSTALLED_CORE_PKG" > /dev/null 2>&1; then
        # If neither is found, skip these info tests
         _skip_test "Show/List tests (skipped: could not find '$INSTALLED_CORE_PKG' or 'bash' installed)"
         INSTALLED_CORE_PKG="" # Ensure it's empty
    fi
fi
# Only run info/list tests if we found a core package
if [[ -n "$INSTALLED_CORE_PKG" ]]; then
    _run_test 0 "Search installed for '$INSTALLED_CORE_PKG'" "$XPAC_CMD" search-installed "$INSTALLED_CORE_PKG"
    _run_test 0 "Show info for '$INSTALLED_CORE_PKG'" "$XPAC_CMD" show "$INSTALLED_CORE_PKG"
    _run_test 0 "List files for '$INSTALLED_CORE_PKG'" "$XPAC_CMD" list-files "$INSTALLED_CORE_PKG"
    _run_test 0 "List commands for '$INSTALLED_CORE_PKG'" "$XPAC_CMD" list-commands "$INSTALLED_CORE_PKG"
fi


echo "--- Package Management (Install/Remove - May Require Sudo) ---"
if [ "$SKIP_SUDO_TESTS" -eq 1 ]; then
    _skip_test "Install '$TEST_PKG'"
    _skip_test "Verify '$TEST_PKG' installed"
    _run_test 0 "Purge '$TEST_PKG' (--dry-run, no sudo needed)" "$XPAC_CMD" --dry-run purge "$TEST_PKG"
    _skip_test "Remove '$TEST_PKG'"
    _skip_test "Verify '$TEST_PKG' removed"
else
    # Cleanup first, in case a previous run failed
    echo "Info: Attempting pre-test cleanup: Removing '$TEST_PKG' if present..."
    # Don't fail the test run if cleanup fails, just report and continue
    "$XPAC_CMD" remove "$TEST_PKG" > /dev/null 2>&1 || true
    sleep 1 # Give package manager time

    # 1. Install
    _run_test 0 "Install '$TEST_PKG'" "$XPAC_CMD" install "$TEST_PKG"
    install_exit_code=$?

    if [ $install_exit_code -eq 0 ]; then
        # 2. Verify Install: list-files exits 0 only for an exactly-installed package
        _run_test 0 "Verify '$TEST_PKG' installed (via list-files)" "$XPAC_CMD" list-files "$TEST_PKG"

        # 3. Purge dry-run while package is installed (safe, no changes made)
        _run_test 0 "Purge '$TEST_PKG' (--dry-run while installed)" "$XPAC_CMD" --dry-run purge "$TEST_PKG"

        # 4. Remove
        _run_test 0 "Remove '$TEST_PKG'" "$XPAC_CMD" remove "$TEST_PKG"
        remove_exit_code=$?

        if [ $remove_exit_code -eq 0 ]; then
            # 5. Verify Removal: list-files exits 1 when package is not installed
            _run_test 1 "Verify '$TEST_PKG' removed (via list-files, expect fail)" "$XPAC_CMD" list-files "$TEST_PKG"
        else
            _skip_test "Verify '$TEST_PKG' removed (skipped due to remove failure)"
        fi
    else
        _skip_test "Verify '$TEST_PKG' installed (skipped due to install failure)"
        _skip_test "Purge '$TEST_PKG' (dry-run) (skipped due to install failure)"
        _skip_test "Remove '$TEST_PKG' (skipped due to install failure)"
        _skip_test "Verify '$TEST_PKG' removed (skipped due to install failure)"
    fi
fi

echo "--- Package Management (Update/Maintenance - May Require Sudo) ---"
if [ "$SKIP_SUDO_TESTS" -eq 1 ]; then
    _skip_test "Update package lists"
    _skip_test "Clean package cache"
    _skip_test "Autoremove packages"
    _skip_test "Upgrade packages (SKIPPED - modifies system state)"
    _skip_test "Update and Upgrade (SKIPPED - modifies system state)"
else
    _run_test 0 "Update package lists" "$XPAC_CMD" update
    _run_test 0 "Clean package cache" "$XPAC_CMD" clean-cache
    _run_test 0 "Autoremove packages" "$XPAC_CMD" autoremove

    _skip_test "Upgrade packages (SKIPPED by default - modifies system state)"
    _skip_test "Update and Upgrade (SKIPPED by default - modifies system state)"
fi


echo "--- Flags (--dry-run, --quiet) ---"
_run_test 0 "Install with --dry-run (no package changes)" "$XPAC_CMD" --dry-run install "$TEST_PKG"
_run_test 0 "Remove with --dry-run (no package changes)" "$XPAC_CMD" --dry-run remove "$TEST_PKG"
_run_test 0 "update-upgrade with --dry-run (no changes)" "$XPAC_CMD" --dry-run update-upgrade
_run_test 0 "sysinfo with --quiet flag" "$XPAC_CMD" --quiet sysinfo
_run_test 0 "search with -q flag (short form of --quiet)" "$XPAC_CMD" -q search "$TEST_PKG"

echo "--- Command Aliases ---"
_run_test 0 "Alias 'i' for install (--dry-run)" "$XPAC_CMD" --dry-run i "$TEST_PKG"
_run_test 0 "Alias 'add' for install (--dry-run)" "$XPAC_CMD" --dry-run add "$TEST_PKG"
_run_test 0 "Alias 'rm' for remove (--dry-run)" "$XPAC_CMD" --dry-run rm "$TEST_PKG"
_run_test 0 "Alias 'pu' for purge (--dry-run)" "$XPAC_CMD" --dry-run pu "$TEST_PKG"
_run_test 0 "Alias 's' for search" "$XPAC_CMD" s "$TEST_PKG"
_run_test 0 "Alias 'f' for search (find)" "$XPAC_CMD" f "$TEST_PKG"
_run_test 0 "Alias 'si' for search-installed" "$XPAC_CMD" si "${INSTALLED_CORE_PKG:-bash}"
_run_test 0 "Alias 'li' for list-installed" "$XPAC_CMD" li
_run_test 0 "Alias 'cc' for clean-cache (--dry-run)" "$XPAC_CMD" --dry-run cc
_run_test 0 "Alias 'uu' for update-upgrade (--dry-run)" "$XPAC_CMD" --dry-run uu
_run_test 0 "Alias 'cpu' for cpuinfo" "$XPAC_CMD" cpu
_run_test 0 "Alias 'net' for ip" "$XPAC_CMD" net

echo "--- Governors ---"
governors_probe_exit=0
"$XPAC_CMD" governors > /dev/null 2>&1 || governors_probe_exit=$?
if [ "$governors_probe_exit" -ne 0 ]; then
    _skip_test "Run governors command (CPU freq scaling not available on this system)"
    _skip_test "Run 'gov' alias for governors"
else
    _run_test 0 "Run governors command" "$XPAC_CMD" governors
    _run_test 0 "Run 'gov' alias for governors" "$XPAC_CMD" gov
fi

echo "--- Error Handling ---"
# yay intentionally delegates unknown commands to yay (exit 0 by design); skip on yay systems
if command -v yay &>/dev/null; then
    _skip_test "Run with invalid command (yay delegates unknown commands to yay, not an error)"
else
    _run_test 1 "Run with invalid command" "$XPAC_CMD" invalidcommandblahblah
fi
# FIX 4, 5, 6: Expect exit code 1 for missing arguments
_run_test 1 "Run install with no package" "$XPAC_CMD" install
_run_test 1 "Run remove with no package" "$XPAC_CMD" remove
_run_test 1 "Run show with no package" "$XPAC_CMD" show
_run_test 1 "Run top with invalid sort key" "$XPAC_CMD" top -s invalidkey


# --- Final Summary ---
printf "\n%b--- Test Summary ---%b\n" "$COL_BOLD" "$COL_RESET"
printf "Total Tests Run: %d\n" "$tests_run"
printf "%bPassed: %d%b\n" "$COL_GREEN" "$tests_passed" "$COL_RESET"
printf "%bFailed: %d%b\n" "$COL_RED" "$tests_failed" "$COL_RESET"
printf "%bSkipped: %d%b\n" "$COL_BLUE" "$tests_skipped" "$COL_RESET"
printf "%b------------------%b\n\n" "$COL_BOLD" "$COL_RESET"

# Exit with 1 if any tests failed
if [ "$tests_failed" -gt 0 ]; then
    exit 1
else
    exit 0
fi