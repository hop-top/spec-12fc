#!/usr/bin/env bash
# Orchestrate kit conformance leaves, aggregate a single JSON report,
# build the per-factor matrix, render the shields.io endpoint-badge
# JSON, and surface step outputs for downstream Action steps.
#
# Exit code is the max of the wrapped leaves; the Action's "Enforce
# verdict" step decides whether that exit code fails the job, based
# on the user's fail-on input.
set -uo pipefail

COMMAND="${INPUT_COMMAND:-all}"
PATHS_CSV="${INPUT_PATHS:-.}"
DIFF="${INPUT_DIFF:-auto}"
CASSETTE_DIR="${INPUT_CASSETTE_DIR:-}"
GRADE_SERVICE="${INPUT_GRADE_SERVICE:-}"
GRADE_TOKEN="${INPUT_GRADE_TOKEN:-}"
GRADE_TIER="${INPUT_GRADE_TIER:-1}"
REPORT_PATH="${INPUT_REPORT_PATH:-12fc-report.json}"
BADGE_PATH="${INPUT_BADGE_PATH:-.12fc.json}"
MATRIX_PATH="${INPUT_MATRIX_PATH:-12fc-matrix.json}"
SARIF_PATH="${INPUT_SARIF_PATH:-12fc.sarif}"

# --paths normaliser: kit accepts --paths=<csv>; we pass through.
PATHS_FLAG="--paths=${PATHS_CSV}"

# --diff=auto: derive from the GitHub Actions event context.
#
# Security: GITHUB_BASE_REF / GITHUB_HEAD_REF / GITHUB_SHA are attacker-
# controlled on pull_request events (PR branch names can contain shell
# metacharacters). We validate each ref against a strict allowlist before
# interpolating into the --diff flag. Anything that fails the regex
# falls back to a full scan rather than a shell-injection vector.
is_safe_ref() {
  # git ref names: alnum, dash, underscore, slash, dot. No '..', no
  # leading '-', no shell metacharacters.
  case "$1" in
    -*|*..*|*' '*|*'$'*|*'`'*|*';'*|*'|'*|*'&'*|*'<'*|*'>'*|*'('*|*')'*|*'"'*|*\'*) return 1 ;;
  esac
  printf '%s' "$1" | grep -Eq '^[A-Za-z0-9._/-]+$'
}

resolve_diff() {
  if [ -z "$DIFF" ]; then echo ""; return; fi
  if [ "$DIFF" != "auto" ]; then
    if is_safe_ref "$DIFF"; then echo "--diff=$DIFF"
    else echo "::warning::rejected unsafe --diff value; falling back to full scan" >&2; echo ""; fi
    return
  fi
  if [ -n "${GITHUB_BASE_REF:-}" ] && [ -n "${GITHUB_SHA:-}" ]; then
    if is_safe_ref "$GITHUB_BASE_REF" && is_safe_ref "$GITHUB_SHA"; then
      echo "--diff=origin/${GITHUB_BASE_REF}...${GITHUB_SHA}"
    else
      echo "::warning::rejected unsafe GITHUB_BASE_REF/GITHUB_SHA; falling back to full scan" >&2
      echo ""
    fi
    return
  fi
  # Push to default branch: full scan.
  echo ""
}
DIFF_FLAG=$(resolve_diff)

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Per-leaf raw outputs land in $tmp; the aggregator reads them.
leaves=()
case "$COMMAND" in
  all)
    leaves=(verify-no-leak verify-stories)
    [ -n "$CASSETTE_DIR" ] && leaves+=(grade)
    ;;
  verify-no-leak|verify-stories|grade)
    leaves=("$COMMAND")
    ;;
  *)
    echo "::error::unknown command: $COMMAND"
    exit 3
    ;;
esac

# Map kit's exit codes to factor verdicts. Same numeric contract as
# conformance.go: 0 clean / 2 leak / 3 usage / 4 io / 5 config.
#
# We avoid bash 4 associative arrays (macOS ships bash 3.2) and instead
# export per-leaf metadata into the environment under stable keys; the
# Python aggregators read them back.
agg_exit=0
export RUN_TMP="$tmp"

for leaf in "${leaves[@]}"; do
  out="$tmp/${leaf}.json"
  echo "::group::kit conformance ${leaf}"
  set +e
  case "$leaf" in
    verify-no-leak)
      kit conformance verify-no-leak \
        ${DIFF_FLAG:+$DIFF_FLAG} \
        ${PATHS_CSV:+$PATHS_FLAG} \
        --format=json >"$out" 2>&1
      rc=$?
      ;;
    verify-stories)
      kit conformance verify-stories \
        ${PATHS_CSV:+$PATHS_FLAG} \
        --format=json >"$out" 2>&1
      rc=$?
      ;;
    grade)
      KIT_CONFORMANCE_SERVICE="$GRADE_SERVICE" \
      KIT_CONFORMANCE_TOKEN="$GRADE_TOKEN" \
        kit conformance grade "$CASSETTE_DIR" \
          --tier="$GRADE_TIER" \
          --format=json >"$out" 2>&1
      rc=$?
      ;;
  esac
  set -e
  echo "exit_code=$rc"
  cat "$out" || true
  echo "::endgroup::"

  key="${leaf//-/_}"
  export "LEAF_JSON_${key}=${out}"
  export "LEAF_EXIT_${key}=${rc}"
  if [ "$rc" -gt "$agg_exit" ]; then agg_exit=$rc; fi
done

# Aggregate report. Schema is intentionally simple so it's stable for
# downstream consumers (shields endpoint, PR comment renderer, SARIF
# converter, third-party CI gates).
python3 - "$REPORT_PATH" "${leaves[@]}" <<'PY'
import json, os, sys, datetime
report_path = sys.argv[1]
leaves = sys.argv[2:]
tmp = os.environ.get("RUN_TMP") or os.path.dirname(report_path) or "."
out = {
  "schemaVersion": 1,
  "specVersion": "12fc/v1",
  "generatedAt": datetime.datetime.utcnow().isoformat(timespec="seconds") + "Z",
  "tool": "kit conformance",
  "commit": os.environ.get("GITHUB_SHA", ""),
  "ref": os.environ.get("GITHUB_REF", ""),
  "leaves": [],
  "findings": [],
  "summary": {"pass": 0, "fail": 0, "skip": 0},
}
for leaf in leaves:
  src = f"/tmp/_unused_{leaf}.json"
  # Resolve from the bash-side temp dir via env.
  src = os.environ.get(f"LEAF_JSON_{leaf.replace('-','_')}", src)
  exit_code = int(os.environ.get(f"LEAF_EXIT_{leaf.replace('-','_')}", "0"))
  try:
    with open(src, "r") as f:
      raw = f.read()
    payload = json.loads(raw) if raw.strip().startswith(("{", "[")) else {"raw": raw}
  except Exception as e:
    payload = {"error": str(e)}
  status = "pass" if exit_code == 0 else ("skip" if exit_code == 4 else "fail")
  out["summary"][status] += 1
  out["leaves"].append({
    "name": leaf,
    "exitCode": exit_code,
    "status": status,
    "payload": payload,
  })
  if isinstance(payload, dict) and isinstance(payload.get("findings"), list):
    for fnd in payload["findings"]:
      fnd2 = dict(fnd) if isinstance(fnd, dict) else {"raw": fnd}
      fnd2["leaf"] = leaf
      out["findings"].append(fnd2)
with open(report_path, "w") as f:
  json.dump(out, f, indent=2)
PY

# Build a per-factor matrix.json from the report. The mapping below
# is conservative: when a factor has no dedicated leaf, it's recorded
# as `skip`. As kit adds more leaves (static / harness / generate-
# stories) this map fills in without changing the consumer contract.
python3 - "$REPORT_PATH" "$MATRIX_PATH" <<'PY'
import json, sys
report_path, matrix_path = sys.argv[1], sys.argv[2]
with open(report_path) as f:
  rep = json.load(f)

# Map leaf name -> factor numbers it covers.
LEAF_TO_FACTORS = {
  "verify-no-leak":   [10],            # F10 Delegation Safety (scenario isolation)
  "verify-stories":   [1, 2, 9, 12],   # F1 introspection, F2 grammar, F9 guidance, F12 evolution
  "grade":            [3, 4, 5, 6, 7, 8, 11],
}

FACTORS = [
  (1,  "Capability Introspection",  "must"),
  (2,  "Intent Clarity",            "must"),
  (3,  "Structured I/O",            "must"),
  (4,  "Corrective Error Model",    "must"),
  (5,  "Explicit Contracts",        "must"),
  (6,  "Previewability",            "must"),
  (7,  "Idempotency",               "must"),
  (8,  "State Transparency",        "must"),
  (9,  "Contextual Guidance",       "should"),
  (10, "Delegation Safety",         "must"),
  (11, "Exit Code Semantics",       "must"),
  (12, "Evolution Guarantees",      "must"),
]

leaf_status = {l["name"]: l["status"] for l in rep["leaves"]}
factor_status = {n: "skip" for n, _, _ in FACTORS}
factor_evidence = {n: "" for n, _, _ in FACTORS}

for leaf, factors in LEAF_TO_FACTORS.items():
  status = leaf_status.get(leaf, "skip")
  for n in factors:
    # Combine: any fail downgrades; pass upgrades from skip.
    if status == "fail":
      factor_status[n] = "fail"
      factor_evidence[n] = f"{leaf} reported findings"
    elif status == "pass" and factor_status[n] != "fail":
      factor_status[n] = "pass"
      factor_evidence[n] = f"{leaf} clean"

matrix = {
  "schemaVersion": 1,
  "factors": [
    {"n": n, "name": name, "tier": tier,
     "status": factor_status[n], "evidence": factor_evidence[n]}
    for (n, name, tier) in FACTORS
  ],
}
with open(matrix_path, "w") as f:
  json.dump(matrix, f, indent=2)
PY

# Generate the shields.io endpoint-badge JSON from the matrix using
# kit's own badge leaf (single source of truth for colour rules).
echo "::group::kit conformance badge --matrix=$MATRIX_PATH"
kit conformance badge --matrix="$MATRIX_PATH" --output="$BADGE_PATH" \
  || echo "::warning::badge generation failed"
echo "::endgroup::"

# Generate SARIF if requested. kit doesn't ship SARIF yet, so we
# synthesize a minimal SARIF v2.1.0 document from the report so
# code-scanning has something to render. Replace with `kit conformance
# ... --format=sarif` once that lands upstream.
if [ -n "$SARIF_PATH" ]; then
python3 - "$REPORT_PATH" "$SARIF_PATH" <<'PY'
import json, sys
report_path, sarif_path = sys.argv[1], sys.argv[2]
with open(report_path) as f:
  rep = json.load(f)
results = []
for fnd in rep.get("findings", []):
  msg = fnd.get("message") or fnd.get("rule") or fnd.get("raw") or "12fc finding"
  loc = fnd.get("path") or fnd.get("file") or ""
  line = int(fnd.get("line") or 1)
  results.append({
    "ruleId": fnd.get("code") or fnd.get("rule") or f"12fc/{fnd.get('leaf','unknown')}",
    "level": "error",
    "message": {"text": msg},
    "locations": [{
      "physicalLocation": {
        "artifactLocation": {"uri": loc} if loc else {"uri": "."},
        "region": {"startLine": line},
      }
    }],
  })
sarif = {
  "version": "2.1.0",
  "$schema": "https://schemastore.azurewebsites.net/schemas/json/sarif-2.1.0.json",
  "runs": [{
    "tool": {"driver": {
      "name": "12fc",
      "informationUri": "https://github.com/hop-top/spec-12fc",
      "rules": [],
    }},
    "results": results,
  }],
}
with open(sarif_path, "w") as f:
  json.dump(sarif, f, indent=2)
PY
fi

# Derive the verdict + badge URL for downstream steps.
verdict=$(python3 -c "
import json
with open('$REPORT_PATH') as f: r = json.load(f)
s = r['summary']
if s['fail'] > 0: print('fail')
elif s['pass'] > 0: print('pass')
else: print('ungradable')
")

findings_count=$(python3 -c "
import json
with open('$REPORT_PATH') as f: r = json.load(f)
print(len(r.get('findings', [])))
")

badge_url=""
if [ -n "${GITHUB_REPOSITORY:-}" ] && [ -n "${GITHUB_REF_NAME:-}" ]; then
  raw="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/${GITHUB_REF_NAME}/${BADGE_PATH}"
  badge_url="https://img.shields.io/endpoint?url=${raw}"
fi

{
  echo "exit-code=$agg_exit"
  echo "verdict=$verdict"
  echo "findings-count=$findings_count"
  echo "report-path=$REPORT_PATH"
  echo "badge-path=$BADGE_PATH"
  echo "badge-url=$badge_url"
} >> "${GITHUB_OUTPUT:-/dev/stdout}"

echo "## 12-Factor CLI Conformance" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
echo "" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
echo "**Verdict:** \`$verdict\` (exit $agg_exit, $findings_count findings)" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
echo "" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
[ -n "$badge_url" ] && echo "![badge]($badge_url)" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

# Propagate the aggregate exit code so the calling step sees it.
exit "$agg_exit"
