#!/usr/bin/env bats

setup() {
  export REPO_ROOT="$BATS_TEST_DIRNAME/.."
}

@test "clashscript without args prints help" {
  run bash -lc "source '$REPO_ROOT/scripts/cmd/script.sh'; clashscript"

  [ "$status" -eq 0 ]
  [[ "$output" == *"clashscript - Clash script manager"* ]]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"clashscript COMMAND [OPTIONS]"* ]]
}

@test "clashscript --help prints help" {
  run bash -lc "source '$REPO_ROOT/scripts/cmd/script.sh'; clashscript --help"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands:"* ]]
  [[ "$output" == *"add [id] <script-path>"* ]]
  [[ "$output" == *"disable <id>"* ]]
}

@test "clashscript -h prints help" {
  run bash -lc "source '$REPO_ROOT/scripts/cmd/script.sh'; clashscript -h"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Examples:"* ]]
  [[ "$output" == *"clashscript enable 1"* ]]
  [[ "$output" == *"clashscript del 1"* ]]
}

@test "clashscript unknown command falls back to help" {
  run bash -lc "source '$REPO_ROOT/scripts/cmd/script.sh'; clashscript unexpected-command"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Notes:"* ]]
  [[ "$output" == *"Scripts must be .js files."* ]]
  [[ "$output" == *"Enabled scripts run automatically"* ]]
}

@test "clashscript add/list/enable/disable/del works with mock metadata" {
  run bash -lc "
    set -e
    tmpdir=\$(mktemp -d)
    chmod +x '$REPO_ROOT/tests/helpers/mock_yq.py'
    source '$REPO_ROOT/scripts/cmd/script.sh'
    CLASH_RESOURCES_DIR=\"\$tmpdir/resources\"
    CLASH_SCRIPTS_DIR=\"\$CLASH_RESOURCES_DIR/scripts\"
    CLASH_SCRIPTS_META=\"\$CLASH_RESOURCES_DIR/scripts.yaml\"
    BIN_YQ='$REPO_ROOT/tests/helpers/mock_yq.py'
    _okcat() { printf '%s\n' \"\$*\"; }
    _failcat() { printf '%s\n' \"\$*\" >&2; return 1; }

    mkdir -p \"\$tmpdir/input\"
    cat > \"\$tmpdir/input/sample.js\" <<'EOF'
function main(config) {
  return config;
}
EOF

    clashscript add \"\$tmpdir/input/sample.js\"
    clashscript ls
    clashscript enable 1
    clashscript ls
    clashscript disable 1
    clashscript del 1

    [ ! -e \"\$CLASH_SCRIPTS_DIR/1_sample.js\" ]
    python3 -c \"import json, pathlib; data = json.loads(pathlib.Path(r'\$CLASH_SCRIPTS_META').read_text(encoding='utf-8')); assert data['scripts'] == [], data\"
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"[1]"* ]]
  [[ "$output" == *"sample.js"* ]]
  [[ "$output" == *"[DISABLED]"* ]]
  [[ "$output" == *"[ENABLED]"* ]]
}

@test "clashscript add with explicit id preserves the provided id" {
  run bash -lc "
    set -e
    tmpdir=\$(mktemp -d)
    chmod +x '$REPO_ROOT/tests/helpers/mock_yq.py'
    source '$REPO_ROOT/scripts/cmd/script.sh'
    CLASH_RESOURCES_DIR=\"\$tmpdir/resources\"
    CLASH_SCRIPTS_DIR=\"\$CLASH_RESOURCES_DIR/scripts\"
    CLASH_SCRIPTS_META=\"\$CLASH_RESOURCES_DIR/scripts.yaml\"
    BIN_YQ='$REPO_ROOT/tests/helpers/mock_yq.py'
    _okcat() { printf '%s\n' \"\$*\"; }
    _failcat() { printf '%s\n' \"\$*\" >&2; return 1; }

    mkdir -p \"\$tmpdir/input\"
    cat > \"\$tmpdir/input/explicit.js\" <<'EOF'
function main(config) {
  return config;
}
EOF

    clashscript add 7 \"\$tmpdir/input/explicit.js\"
    clashscript ls
    grep -q '7_explicit.js' \"\$CLASH_SCRIPTS_META\"
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"[7]"* ]]
  [[ "$output" == *"explicit.js"* ]]
  [[ "$output" == *"[DISABLED]"* ]]
}
