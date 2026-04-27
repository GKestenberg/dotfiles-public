#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""Create/update dockerhub-secret in k8s and patch ServiceAccounts to use it.

Pass entries expected:
  kubernetes/dockerhub/username
  kubernetes/dockerhub/token
  kubernetes/dockerhub/email

Optional env overrides:
  NAMESPACES    - comma-separated list (default: default,monitoring)
  SECRET_NAME   - default: dockerhub-secret
  PATCH_SAS     - "all" | "default" | "none" (default: all)
                  all     = every SA in the namespace
                  default = only the `default` SA
                  none    = skip patching
"""

from __future__ import annotations

import json
import os
import subprocess
import sys


REGISTRY_SERVER = "https://index.docker.io/v1/"


def pass_get(key: str) -> str:
    try:
        result = subprocess.run(
            ["pass", f"kubernetes/dockerhub/{key}"],
            capture_output=True,
            text=True,
            timeout=3,
            check=True,
        )
    except subprocess.TimeoutExpired:
        sys.exit(f"ERROR: timeout reading kubernetes/dockerhub/{key} from pass")
    except subprocess.CalledProcessError as e:
        sys.exit(f"ERROR: kubernetes/dockerhub/{key}: {e.stderr.strip()}")

    val = result.stdout.strip()
    if not val:
        sys.exit(f"ERROR: kubernetes/dockerhub/{key} is empty")
    return val


def ensure_namespace(namespace: str) -> None:
    check = subprocess.run(
        ["kubectl", "get", "namespace", namespace],
        capture_output=True,
    )
    if check.returncode != 0:
        subprocess.run(["kubectl", "create", "namespace", namespace], check=True)


def apply_secret(namespace: str, secret_name: str, username: str, token: str, email: str) -> None:
    rendered = subprocess.run(
        [
            "kubectl", "create", "secret", "docker-registry", secret_name,
            f"--namespace={namespace}",
            f"--docker-server={REGISTRY_SERVER}",
            f"--docker-username={username}",
            f"--docker-password={token}",
            f"--docker-email={email}",
            "--dry-run=client",
            "-o", "yaml",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    subprocess.run(
        ["kubectl", "apply", "-f", "-"],
        input=rendered.stdout,
        text=True,
        check=True,
    )


def list_service_accounts(namespace: str) -> list[str]:
    result = subprocess.run(
        ["kubectl", "-n", namespace, "get", "sa", "-o", "name"],
        capture_output=True,
        text=True,
        check=True,
    )
    # output lines look like: serviceaccount/default
    return [
        line.split("/", 1)[1]
        for line in result.stdout.strip().splitlines()
        if line.strip()
    ]


def patch_sa(namespace: str, sa: str, secret_name: str) -> None:
    """Strategic-merge patch is idempotent here:
    imagePullSecrets uses patchMergeKey=name, so re-running won't duplicate.
    """
    patch = json.dumps({"imagePullSecrets": [{"name": secret_name}]})
    subprocess.run(
        ["kubectl", "-n", namespace, "patch", "sa", sa, "-p", patch],
        check=True,
    )


def main() -> int:
    namespaces = [
        n.strip()
        for n in os.environ.get("NAMESPACES", "default,monitoring").split(",")
        if n.strip()
    ]
    secret_name = os.environ.get("SECRET_NAME", "dockerhub-secret")
    patch_mode = os.environ.get("PATCH_SAS", "all").lower()
    if patch_mode not in {"all", "default", "none"}:
        sys.exit(f"ERROR: PATCH_SAS must be all|default|none, got {patch_mode!r}")

    username = pass_get("username")
    token = pass_get("token")
    email = pass_get("email")

    for namespace in namespaces:
        print(f"\n=== {namespace} ===")
        ensure_namespace(namespace)

        print(f"Applying secret {namespace}/{secret_name} for {username}")
        apply_secret(namespace, secret_name, username, token, email)

        if patch_mode == "none":
            continue

        sas = ["default"] if patch_mode == "default" else list_service_accounts(namespace)
        for sa in sas:
            print(f"Patching ServiceAccount {namespace}/{sa}")
            patch_sa(namespace, sa, secret_name)

    print("\nVerify:")
    for namespace in namespaces:
        print(f"  kubectl -n {namespace} get secret {secret_name}")
        print(f"  kubectl -n {namespace} get sa -o yaml | grep -A1 imagePullSecrets")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
