#!/usr/bin/env bash

THIS_SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE:-${(%):-%N}}")")
. "$THIS_SCRIPT_DIR/common.sh"

CLASH_SCRIPTS_DIR="${CLASH_RESOURCES_DIR}/scripts"
CLASH_SCRIPTS_META="${CLASH_RESOURCES_DIR}/scripts.yaml"
BIN_NODE=$(command -v node || echo "")
BIN_JS_EXECUTOR="${THIS_SCRIPT_DIR}/../js/executor.js"

function clashscript() {
    case "$1" in
    -h | --help | "")
        _script_help
        ;;
    add)
        shift
        _script_add "$@"
        ;;
    del)
        shift
        _script_del "$@"
        ;;
    list | ls)
        _script_list
        ;;
    enable)
        shift
        _script_enable "$@"
        ;;
    disable)
        shift
        _script_disable "$@"
        ;;
    *)
        _script_help
        ;;
    esac
}

_script_help() {
    cat <<EOF
clashscript - Clash script manager

Usage:
  clashscript COMMAND [OPTIONS]

Commands:
  add [id] <script-path>   Add a JS script, auto-assign ID when omitted
  ls                       List all scripts
  del <id>                 Delete a script
  enable <id>              Enable a script
  disable <id>             Disable a script

Examples:
  clashscript add examples/scripts/auto-group.js
  clashscript add 1 examples/scripts/auto-group.js
  clashscript ls
  clashscript enable 1
  clashscript disable 1
  clashscript del 1

Notes:
  Scripts must be .js files.
  Script ID should match the profile ID you want to process.
  Enabled scripts run automatically when the related profile is used or updated.
EOF
}

_script_add() {
    local id script_path

    if [[ $# -eq 1 ]]; then
        script_path=$1
        id=$(_get_next_available_id)
    elif [[ $# -eq 2 ]]; then
        id=$1
        script_path=$2
    else
        _failcat "Usage: clashscript add [id] <script-path>"
        return 1
    fi

    [ ! -f "$script_path" ] && { _failcat "Script file not found: $script_path"; return 1; }
    [[ "$script_path" != *.js ]] && { _failcat "Script file must end with .js"; return 1; }

    mkdir -p "$CLASH_SCRIPTS_DIR"

    if [ ! -f "$CLASH_SCRIPTS_META" ]; then
        echo "scripts: []" > "$CLASH_SCRIPTS_META"
    fi

    local existing_id
    existing_id=$("$BIN_YQ" ".scripts[] | select(.id == $id) | .id" "$CLASH_SCRIPTS_META" 2>/dev/null)
    [ -n "$existing_id" ] && { _failcat "Script ID already exists: $id"; return 1; }

    local script_name
    script_name=$(basename "$script_path")
    local new_path="${CLASH_SCRIPTS_DIR}/${id}_${script_name}"

    cp "$script_path" "$new_path"

    "$BIN_YQ" -i ".scripts += [{\"id\": $id, \"name\": \"$script_name\", \"path\": \"$new_path\", \"enabled\": false}]" "$CLASH_SCRIPTS_META"

    _sort_scripts

    _okcat "INFO" "Added script [$id] $script_name (profile $id)"
}

_get_next_available_id() {
    local existing_ids next_id=1

    if [ ! -f "$CLASH_SCRIPTS_META" ]; then
        echo 1
        return
    fi

    existing_ids=$("$BIN_YQ" -r '.scripts[].id' "$CLASH_SCRIPTS_META" 2>/dev/null | sort -n)

    if [ -z "$existing_ids" ]; then
        echo 1
        return
    fi

    while IFS= read -r existing_id; do
        [ -n "$existing_id" ] || continue
        if [ "$next_id" -lt "$existing_id" ]; then
            echo "$next_id"
            return
        fi
        next_id=$((existing_id + 1))
    done <<< "$existing_ids"

    echo "$next_id"
}

_sort_scripts() {
    [ ! -f "$CLASH_SCRIPTS_META" ] && return
    "$BIN_YQ" -i '.scripts |= sort_by(.id)' "$CLASH_SCRIPTS_META" 2>/dev/null
}

_script_del() {
    local id=$1
    [ -z "$id" ] && { _failcat "Usage: clashscript del <id>"; return 1; }
    [ ! -f "$CLASH_SCRIPTS_META" ] && { _failcat "No scripts found."; return 1; }

    local path
    path=$("$BIN_YQ" -r ".scripts[] | select(.id == $id) | .path" "$CLASH_SCRIPTS_META" 2>/dev/null)
    [ -z "$path" ] && { _failcat "Script not found: $id"; return 1; }

    rm -f "$path"
    "$BIN_YQ" -i "del(.scripts[] | select(.id == $id))" "$CLASH_SCRIPTS_META"

    _sort_scripts

    _okcat "INFO" "Deleted script [$id]"
}

_script_list() {
    [ ! -f "$CLASH_SCRIPTS_META" ] && { _failcat "No scripts found."; return 1; }

    local data
    data=$("$BIN_YQ" eval '.scripts[] | [.id, .name, .enabled] | @tsv' "$CLASH_SCRIPTS_META" 2>/dev/null)

    [ -z "$data" ] && { _failcat "No scripts found."; return 1; }

    echo "$data" | while IFS=$'\t' read -r id name enabled; do
        local state="[DISABLED]"
        [ "$enabled" = "true" ] && state="[ENABLED]"
        printf "[%d] %-20s %s\n" "$id" "$name" "$state"
    done
}

_script_enable() {
    local id=$1
    [ -z "$id" ] && { _failcat "Usage: clashscript enable <id>"; return 1; }
    [ ! -f "$CLASH_SCRIPTS_META" ] && { _failcat "No scripts found."; return 1; }

    local exists
    exists=$("$BIN_YQ" ".scripts[] | select(.id == $id) | .id" "$CLASH_SCRIPTS_META" 2>/dev/null)
    [ -z "$exists" ] && { _failcat "Script not found: $id"; return 1; }

    "$BIN_YQ" -i "(.scripts[] | select(.id == $id) | .enabled) = true" "$CLASH_SCRIPTS_META"

    _okcat "INFO" "Enabled script [$id] (profile $id)"
}

_script_disable() {
    local id=$1
    [ -z "$id" ] && { _failcat "Usage: clashscript disable <id>"; return 1; }
    [ ! -f "$CLASH_SCRIPTS_META" ] && { _failcat "No scripts found."; return 1; }

    local exists
    exists=$("$BIN_YQ" ".scripts[] | select(.id == $id) | .id" "$CLASH_SCRIPTS_META" 2>/dev/null)
    [ -z "$exists" ] && { _failcat "Script not found: $id"; return 1; }

    "$BIN_YQ" -i "(.scripts[] | select(.id == $id) | .enabled) = false" "$CLASH_SCRIPTS_META"

    _okcat "INFO" "Disabled script [$id]"
}

function execute_scripts() {
    local config_file=$1
    local profile_id=$2

    [ ! -f "$CLASH_SCRIPTS_META" ] && return 0
    [ -z "$BIN_NODE" ] && { _failcat "Node.js is required to execute scripts"; return 1; }

    local script_path
    script_path=$("$BIN_YQ" -r ".scripts[] | select(.id == $profile_id and .enabled == true) | .path" "$CLASH_SCRIPTS_META" 2>/dev/null)

    [ -z "$script_path" ] && return 0
    [ ! -f "$script_path" ] && {
        _failcat "Script file not found: $script_path"
        return 1
    }

    _okcat "RUN" "Executing script: $(basename "$script_path")"

    local error_output
    error_output=$("$BIN_NODE" "$BIN_JS_EXECUTOR" "$config_file" "$script_path" "profile_$profile_id" 2>&1)
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        _failcat "Script execution failed (exit code: $exit_code)"
        [ -n "$error_output" ] && {
            echo "Error details:" >&2
            echo "$error_output" >&2
        }
        return 1
    fi
}

function _init_script_system() {
    mkdir -p "$CLASH_SCRIPTS_DIR"
    [ ! -f "$CLASH_SCRIPTS_META" ] && echo "scripts: []" > "$CLASH_SCRIPTS_META"
}
