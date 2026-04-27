#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["boto3"]
# ///
"""Delete customer-managed IAM policies whose name contains a pattern."""

from __future__ import annotations

import sys

import boto3
from botocore.exceptions import ClientError


def main() -> int:
    pattern = sys.argv[1] if len(sys.argv) > 1 else "porter"
    iam = boto3.client("iam")

    print(f"Searching for customer-managed policies matching: {pattern}\n")

    matches: list[dict] = []
    paginator = iam.get_paginator("list_policies")
    for page in paginator.paginate(Scope="Local"):
        for p in page["Policies"]:
            if pattern in p["PolicyName"]:
                matches.append(p)
                print(f"  {p['PolicyName']:<60}  attached={p['AttachmentCount']}")

    if not matches:
        print("No matching policies found.")
        return 0

    print(f"\nFound {len(matches)} policy(ies).")
    reply = input("Delete them? [y/N] ").strip().lower()
    if reply not in ("y", "yes"):
        print("Aborted.")
        return 0

    for p in matches:
        arn, name = p["Arn"], p["PolicyName"]
        print(f"\nDeleting {name}")
        try:
            entities = iam.list_entities_for_policy(PolicyArn=arn)
            for u in entities.get("PolicyUsers", []):
                iam.detach_user_policy(UserName=u["UserName"], PolicyArn=arn)
            for g in entities.get("PolicyGroups", []):
                iam.detach_group_policy(GroupName=g["GroupName"], PolicyArn=arn)
            for r in entities.get("PolicyRoles", []):
                iam.detach_role_policy(RoleName=r["RoleName"], PolicyArn=arn)

            versions = iam.list_policy_versions(PolicyArn=arn)["Versions"]
            for v in versions:
                if not v["IsDefaultVersion"]:
                    iam.delete_policy_version(PolicyArn=arn, VersionId=v["VersionId"])

            iam.delete_policy(PolicyArn=arn)
            print("  done.")
        except ClientError as e:
            print(f"  FAILED: {e}", file=sys.stderr)

    print("\nDone.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
