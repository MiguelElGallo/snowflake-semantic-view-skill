#!/usr/bin/env python3
"""Build a Snowflake SQL call for SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML."""

from __future__ import annotations

import argparse
from pathlib import Path


def choose_delimiter(text: str) -> str:
    base = "$$"
    if base not in text:
        return base
    for idx in range(1, 100):
        candidate = f"$yaml_{idx}$"
        if candidate not in text:
            return candidate
    raise ValueError("Could not find a safe dollar-quote delimiter for YAML")


def sql_string_literal(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def build_sql(yaml_path: Path, schema: str, verify_only: bool) -> str:
    yaml_text = yaml_path.read_text(encoding="utf-8")
    delimiter = choose_delimiter(yaml_text)
    verify = "TRUE" if verify_only else "FALSE"
    return (
        "CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(\n"
        f"  {sql_string_literal(schema)},\n"
        f"  {delimiter}\n{yaml_text}\n{delimiter},\n"
        f"  {verify}\n"
        ");\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate SQL to verify or deploy a Snowflake semantic view YAML file."
    )
    parser.add_argument("yaml_file", type=Path)
    parser.add_argument(
        "--schema",
        required=True,
        help="Fully qualified target schema, for example DB.SCHEMA.",
    )
    parser.add_argument(
        "--verify-only",
        action="store_true",
        help="Set verify_only=TRUE so Snowflake validates without creating/replacing.",
    )
    args = parser.parse_args()

    if "." not in args.schema:
        raise SystemExit("--schema must be fully qualified as DB.SCHEMA")
    if not args.yaml_file.is_file():
        raise SystemExit(f"YAML file not found: {args.yaml_file}")

    print(build_sql(args.yaml_file, args.schema, args.verify_only), end="")


if __name__ == "__main__":
    main()
