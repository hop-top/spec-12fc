#!/usr/bin/env bash
# Local smoke test for the 12fcc Action scripts.
#
# Strategy: substitute a stub `kit` binary on PATH, run scripts/run.sh
# against a fixture, assert the produced report / matrix / badge match
# expected shape and verdict.
#
# Runs three scenarios:
#   clean   → exit 0, verdict=pass, badge color=brightgreen
#   leaky   → exit 2, verdict=fail, badge color=red
#   broken  → exit 5, verdict=fail, badge color=red
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
fail_count=0
pass_count=0

step() { printf "\n\033[1;36m▶ %s\033[0m\n" "$*"; }
ok()   { printf "  \033[1;32m✓\033[0m %s\n" "$*"; pass_count=$((pass_count+1)); }
fail() { printf "  \033[1;31m✗\033[0m %s\n" "$*"; fail_count=$((fail_count+1)); }

assert_eq() {
  local actual="$1" expected="$2" label="$3"
  if [ "$actual" = "$expected" ]; then ok "$label = $expected"
  else fail "$label expected '$expected' got '$actual'"; fi
}

assert_json_path() {
  local file="$1" path="$2" expected="$3" label="$4"
  local actual
  actual=$(python3 -c "import json; d=json.load(open('$file')); print(d$path)")
  assert_eq "$actual" "$expected" "$label"
}

run_scenario() {
  local mode="$1" expect_exit="$2" expect_verdict="$3" expect_color="$4"
  step "scenario: $mode"

  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN

  # Prepend stub to PATH so `kit` resolves to it.
  cp "$root/test/stubs/kit" "$tmp/kit"
  chmod +x "$tmp/kit"
  export PATH="$tmp:$PATH"
  export KIT_STUB_MODE="$mode"
  export INPUT_COMMAND=all
  export INPUT_PATHS=.
  export INPUT_DIFF=""
  export INPUT_REPORT_PATH="$tmp/report.json"
  export INPUT_BADGE_PATH="$tmp/badge.json"
  export INPUT_MATRIX_PATH="$tmp/matrix.json"
  export INPUT_SARIF_PATH="$tmp/result.sarif"
  export GITHUB_OUTPUT="$tmp/outputs"
  export GITHUB_STEP_SUMMARY="$tmp/summary.md"
  : >"$GITHUB_OUTPUT"
  : >"$GITHUB_STEP_SUMMARY"

  # Capture exit without aborting the harness.
  set +e
  bash "$root/scripts/run.sh" >"$tmp/stdout" 2>"$tmp/stderr"
  rc=$?
  set -e

  assert_eq "$rc" "$expect_exit" "exit code"

  # report.json shape
  if [ ! -f "$tmp/report.json" ]; then
    fail "report.json missing"
    return
  fi
  assert_json_path "$tmp/report.json" "['schemaVersion']" "1" "report.schemaVersion"
  assert_json_path "$tmp/report.json" "['specVersion']" "12fcc/v1" "report.specVersion"

  # matrix.json shape: 12 factors
  if [ ! -f "$tmp/matrix.json" ]; then
    fail "matrix.json missing"
    return
  fi
  assert_json_path "$tmp/matrix.json" "['schemaVersion']" "1" "matrix.schemaVersion"
  local factor_count
  factor_count=$(python3 -c "import json;print(len(json.load(open('$tmp/matrix.json'))['factors']))")
  assert_eq "$factor_count" "12" "matrix.factors.length"

  # badge.json color
  if [ ! -f "$tmp/badge.json" ]; then
    fail "badge.json missing"
    return
  fi
  assert_json_path "$tmp/badge.json" "['color']" "$expect_color" "badge.color"

  # SARIF shape
  if [ ! -f "$tmp/result.sarif" ]; then
    fail "result.sarif missing"
    return
  fi
  assert_json_path "$tmp/result.sarif" "['version']" "2.1.0" "sarif.version"

  # GITHUB_OUTPUT carries verdict + exit-code
  if ! grep -q "^verdict=$expect_verdict$" "$tmp/outputs"; then
    fail "outputs.verdict expected '$expect_verdict'"
    sed 's/^/    /' "$tmp/outputs"
  else
    ok "outputs.verdict = $expect_verdict"
  fi
  if ! grep -q "^exit-code=$expect_exit$" "$tmp/outputs"; then
    fail "outputs.exit-code expected '$expect_exit'"
  else
    ok "outputs.exit-code = $expect_exit"
  fi

  # Step summary not empty
  if [ -s "$GITHUB_STEP_SUMMARY" ]; then
    ok "step summary written ($(wc -c <"$GITHUB_STEP_SUMMARY" | tr -d ' ') bytes)"
  else
    fail "step summary empty"
  fi
}

# Scenario 1: clean (no grade leaf wired) → 0 / pass / lightgrey
# Without `grade`, factors F3/F4/F5/F6/F7/F8/F11 stay `skip`; the
# stub renders any non-uniform matrix as lightgrey. This matches the
# "ungradable until full suite runs" badge semantics in kit.
run_scenario clean 0 pass lightgrey

# Scenario 2: leaky → 2 / fail / red
run_scenario leaky 2 fail red

# Scenario 3: broken → 5 / fail / red
run_scenario broken 5 fail red

# Scenario 4: injection attempt via --diff. A malicious branch name like
# `$(touch pwned)` MUST be rejected by is_safe_ref and fall back to a
# full scan rather than execute. Regression guard.
step "scenario: ref-injection attempt"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' RETURN
cp "$root/test/stubs/kit" "$tmp/kit"; chmod +x "$tmp/kit"
export PATH="$tmp:$PATH"
export KIT_STUB_MODE=clean
export INPUT_COMMAND=verify-no-leak
export INPUT_PATHS=.
export INPUT_DIFF='$(touch '"$tmp"'/pwned)'
export INPUT_REPORT_PATH="$tmp/report.json"
export INPUT_BADGE_PATH="$tmp/badge.json"
export INPUT_MATRIX_PATH="$tmp/matrix.json"
export INPUT_SARIF_PATH="$tmp/result.sarif"
export GITHUB_OUTPUT="$tmp/outputs"
export GITHUB_STEP_SUMMARY="$tmp/summary.md"
: >"$GITHUB_OUTPUT"; : >"$GITHUB_STEP_SUMMARY"
set +e; bash "$root/scripts/run.sh" >"$tmp/stdout" 2>"$tmp/stderr"; rc=$?; set -e
assert_eq "$rc" "0" "injection scenario exit"
if [ -e "$tmp/pwned" ]; then fail "injection executed — pwned file created"
else ok "injection rejected; no pwned file"; fi
if grep -q "rejected unsafe --diff" "$tmp/stderr"; then ok "warning surfaced"
else fail "expected rejection warning on stderr"; fi

printf "\n\033[1m── summary ──\033[0m\n"
printf "  pass: \033[1;32m%d\033[0m\n" "$pass_count"
printf "  fail: \033[1;31m%d\033[0m\n" "$fail_count"

if [ "$fail_count" -gt 0 ]; then exit 1; fi
echo "all smoke tests passed"
