# AGENTS.md — Guidelines for AI Coding Agents

## Project Overview

This is **clash-for-linux-install**, a Bash-based installer and manager for the Clash/Mihomo proxy kernel on Linux. It supports systemd, SysVinit, OpenRC, runit, and nohup as init systems. The project is entirely shell scripts (Bash) with a small set of JS example scripts.

## Repository Structure

```
.
├── .env                  # Environment config (kernel name, install path, versions)
├── install.sh            # Main installation entry point
├── uninstall.sh          # Uninstallation script
├── scripts/
│   ├── preflight.sh      # Validation, init detection, service management, download logic
│   └── cmd/
│       ├── common.sh     # Shared variables, utility functions (logging, download, config)
│       └── clashctl.sh   # Core CLI commands (clashon, clashoff, clashsub, etc.)
├── scripts/init/         # Init system templates (systemd.sh, SysVinit.sh, OpenRC.sh, runit.sh)
├── bin/                  # Compiled binaries (mihomo, yq, subconverter)
├── resources/            # Config templates, GeoIP data, profiles, UI zip
├── examples/scripts/     # JS example scripts for yq-based config manipulation
└── .github/workflows/    # CI (only stale-issues.yml)
```

### Key Sourcing Chains

- `install.sh` sources `scripts/cmd/clashctl.sh` → `scripts/cmd/common.sh` → `.env`
- `install.sh` also sources `scripts/preflight.sh` (uses variables from `clashctl.sh` / `common.sh`)
- `uninstall.sh` sources both the installed `clashctl.sh` and local `scripts/preflight.sh`
- `clashctl.sh` sets `THIS_SCRIPT_DIR` and sources `common.sh` relative to it

## Build / Lint / Test Commands

There is **no formal build system, test suite, or CI pipeline** for linting/testing. Changes are validated by running the scripts directly.

### Linting with ShellCheck

The project has a `.shellcheckrc` with specific disabled rules. Run ShellCheck manually:

```bash
# Lint all scripts
shellcheck install.sh uninstall.sh scripts/preflight.sh scripts/cmd/*.sh

# Lint a single file
shellcheck scripts/cmd/clashctl.sh
```

Disabled ShellCheck rules (see `.shellcheckrc`):
- `SC1091` — Not following sourced files
- `SC2155` — Declare and assign separately
- `SC2296` — Expanding inside array/associative
- `SC2153` — Variable may not be referenced

### Testing

No automated tests exist. To verify changes:
1. Run `shellcheck` on modified files
2. Test in a disposable Linux environment (VM/container) with `./install.sh`
3. Source `clashctl.sh` and exercise individual functions: `source scripts/cmd/clashctl.sh && clashhelp`

## Code Style Guidelines

### Formatting
- **Indentation**: 2 spaces (per `.editorconfig` and `.gitattributes` enforcing LF line endings)
- **Line endings**: LF only
- Always use `#!/usr/bin/env bash` shebang

### Naming Conventions
- **Public CLI functions** (user-facing commands): `camelCase` — e.g., `clashon()`, `clashoff()`, `clashsub()`, `clashctl()`
- **Internal/helper functions**: `_underscore_prefix` + `snake_case` — e.g., `_set_system_proxy()`, `_valid_config()`, `_detect_init()`
- **Constants/path variables**: `UPPER_SNAKE_CASE` — e.g., `CLASH_BASE_DIR`, `BIN_KERNEL`, `EXT_IP`
- **Local variables**: `camelCase` or `snake_case` with `local` keyword — e.g., `local mixed_port`, `local allowLan`
- **Global exports** used across scripts: `UPPER_SNAKE_CASE`

### Imports / Sourcing
- Use `. <path>` syntax (POSIX-compatible sourcing), not `source`
- Source files relative to `THIS_SCRIPT_DIR` using `dirname "$(readlink -f "${BASH_SOURCE:-${(%):-%N}}")"`
- Environment config is loaded from `.env` at the top level: `. "$(dirname "$(dirname "$THIS_SCRIPT_DIR")")/.env"`

### Error Handling
- Use `_error_quit` for fatal errors — prints a colored message and execs into a new shell
- Use `_failcat` for non-fatal warnings — prints to stderr and returns 1
- Use `_okcat` for success/info messages — prints to stdout and returns 0
- Always check command exit codes; use `||` / `&&` short-circuit patterns
- Quote all variable expansions: `"$var"`, `"${array[@]}"`

### General Shell Patterns
- Use `local` for all function-scoped variables
- Prefer `[[ ]]` for conditionals over `[ ]`
- Use `>&/dev/null` or `>/dev/null 2>&1` to suppress output when discarding
- Use arrays for command composition: `local cmd=(arg1 arg2); "${cmd[@]}"`
- Avoid pipelines where possible; use `$()` command substitution
- Use `case` statements for argument parsing, not `getopt`
- Disable specific ShellCheck rules inline with `# shellcheck disable=SCxxxx` only when necessary

### YAML Handling
- All YAML manipulation goes through `yq` (the binary at `$BIN_YQ`)
- Use `-i` flag for in-place edits
- Quote yq expressions in single quotes; use `--` for complex expressions

### Comments
- Use section comments with box-style headers in long yq expressions (see `_merge_config` in `clashctl.sh`)
- Avoid comments in general code unless explaining non-obvious logic

## Configuration Merge System

The `_merge_config` function in `clashctl.sh` is central to the runtime config pipeline. It merges:
1. **Base config** (`config.yaml`) — the subscription/remote config
2. **Mixin config** (`mixin.yaml`) — user overrides with prefix/suffix rules, proxy overrides, and `_custom` metadata
3. The merged result becomes `runtime.yaml`, validated against the kernel binary

When modifying config-related code, always ensure `_valid_config` is called after any merge to prevent broken runtime state.

## Init System Templates

Templates in `scripts/init/` use placeholder tokens (e.g., `placeholder_cmd_full`, `placeholder_log_file`) that are replaced at install time by `_install_service` in `preflight.sh`. The function array variables (`service_start`, `service_stop`, etc.) are dynamically populated per init system and injected into `clashctl.sh` via `sed`.

## Common Development Tasks

- **Add a new CLI command**: Define a `function` in `clashctl.sh`, add a case entry in `clashctl()`, and document in `clashhelp()`
- **Modify init logic**: Edit the corresponding `scripts/init/*.sh` template and update `_install_service` / `_uninstall_service` in `preflight.sh`
- **Update binary versions**: Edit `VERSION_*` variables in `.env`
- **Change download URLs**: Update `_download_zip` in `preflight.sh` (architecture-specific)
