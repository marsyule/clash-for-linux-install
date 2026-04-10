#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path


def load_data(path: Path):
    if not path.exists():
        return {"scripts": []}

    raw = path.read_text(encoding="utf-8").strip()
    if not raw:
        return {"scripts": []}
    if raw == "scripts: []":
        return {"scripts": []}
    if raw.startswith("{"):
        return json.loads(raw)
    raise SystemExit(f"Unsupported mock yq input: {raw}")


def save_data(path: Path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def find_script(data, script_id):
    for item in data.get("scripts", []):
        if int(item["id"]) == int(script_id):
            return item
    return None


def main():
    args = sys.argv[1:]
    in_place = False
    raw_output = False

    while args and args[0] in {"-i", "-r"}:
        if args[0] == "-i":
            in_place = True
        elif args[0] == "-r":
            raw_output = True
        args = args[1:]

    if not args:
        raise SystemExit("Missing expression")

    if args[0] == "eval":
        args = args[1:]

    if len(args) != 2:
        raise SystemExit("Expected expression and file")

    expr, file_path = args
    path = Path(file_path)
    data = load_data(path)

    if expr == ".scripts |= sort_by(.id)":
        data["scripts"] = sorted(data.get("scripts", []), key=lambda item: int(item["id"]))
        if in_place:
            save_data(path, data)
        return

    match = re.fullmatch(r'\.scripts \+= \[(.*)\]', expr)
    if match:
        items = json.loads(f'[{match.group(1)}]')
        data.setdefault("scripts", []).extend(items)
        if in_place:
            save_data(path, data)
        return

    match = re.fullmatch(r'del\(\.scripts\[\] \| select\(\.id == (\d+)\)\)', expr)
    if match:
        script_id = int(match.group(1))
        data["scripts"] = [item for item in data.get("scripts", []) if int(item["id"]) != script_id]
        if in_place:
            save_data(path, data)
        return

    match = re.fullmatch(r'\(\.scripts\[\] \| select\(\.id == (\d+)\) \| \.enabled\) = (true|false)', expr)
    if match:
        script_id = int(match.group(1))
        enabled = match.group(2) == "true"
        item = find_script(data, script_id)
        if item is not None:
            item["enabled"] = enabled
        if in_place:
            save_data(path, data)
        return

    match = re.fullmatch(r'\.scripts\[\] \| select\(\.id == (\d+)\) \| \.id', expr)
    if match:
        item = find_script(data, int(match.group(1)))
        if item is not None:
            print(item["id"])
        return

    match = re.fullmatch(r'\.scripts\[\] \| select\(\.id == (\d+)\) \| \.path', expr)
    if match:
        item = find_script(data, int(match.group(1)))
        if item is not None:
            print(item["path"])
        return

    if expr == ".scripts[].id":
        for item in data.get("scripts", []):
            print(item["id"])
        return

    if expr == ".scripts[] | [.id, .name, .enabled] | @tsv":
        for item in data.get("scripts", []):
            print(f'{item["id"]}\t{item["name"]}\t{str(item["enabled"]).lower()}')
        return

    if raw_output:
        return

    raise SystemExit(f"Unsupported mock yq expression: {expr}")


if __name__ == "__main__":
    main()
