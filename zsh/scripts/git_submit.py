# /// script
# requires-python = ">=3.11"
# dependencies = ["anthropic>=0.40.0", "httpx>=0.27"]
# ///
"""Rebase, push, and ensure the PR is linked to a Linear issue.

Flow:
  1. Rebase current branch onto base with --update-refs.
  2. Find or create a Linear issue assigned to me (searches GIL + RUN):
       - fetch open issues assigned to me across both teams
       - ask Claude to match the diff against them
       - on no match: draft + create a new GIL issue (with confirmation)
  3. If a PR exists: push (force-with-lease) and ensure the body
     references the Linear issue.
     If no PR: ask Claude for title/description/type, push, and create
     the PR titled "${type}: [TEAM - N] ${name}".

Usage:
    g_s
    g_s --base develop
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys

import anthropic
import httpx

LINEAR_API = "https://api.linear.app/graphql"
TEAM_KEYS = ["GIL", "RUN"]
MODEL = "claude-opus-4-7"
MAX_DIFF_CHARS = 60_000


# --- shell helpers -------------------------------------------------------

def run(cmd: list[str], **kw) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, text=True, **kw)


def run_check(cmd: list[str]) -> str:
    r = run(cmd, capture_output=True)
    if r.returncode != 0:
        sys.stderr.write(r.stderr)
        sys.exit(r.returncode)
    return r.stdout


def pass_get(path: str) -> str:
    r = run(["pass", path], capture_output=True)
    if r.returncode != 0:
        sys.stderr.write(f"g_s: failed to read pass {path}\n{r.stderr}")
        sys.exit(1)
    return r.stdout.strip()


# --- git -----------------------------------------------------------------

def current_branch() -> str:
    return run_check(["git", "rev-parse", "--abbrev-ref", "HEAD"]).strip()


def rebase(base: str) -> None:
    print(f"==> Rebasing onto {base} with --update-refs", file=sys.stderr)
    r = run(["git", "rebase", "--update-refs", base])
    if r.returncode == 0:
        return

    if not in_rebase():
        sys.stderr.write("\nRebase failed for a non-conflict reason.\n")
        sys.exit(r.returncode)

    while in_rebase():
        conflicts = run_check(["git", "diff", "--name-only", "--diff-filter=U"]).split()
        if not conflicts:
            # No conflicts but still mid-rebase — git wants us to continue
            cont = run(["git", "-c", "core.editor=true", "rebase", "--continue"])
            if cont.returncode != 0:
                sys.exit(cont.returncode)
            continue

        print(f"==> Conflicts in: {', '.join(conflicts)}", file=sys.stderr)
        if not claude_resolve(conflicts, base):
            sys.stderr.write("\nClaude could not resolve. Drop into manual mode.\n")
            sys.exit(1)

        # Stage Claude's resolutions and continue
        run_check(["git", "add", "--", *conflicts])
        cont = run(["git", "-c", "core.editor=true", "rebase", "--continue"])
        if cont.returncode != 0:
            # Could be more conflicts on the next commit — loop will catch it
            continue


def in_rebase() -> bool:
    git_dir = run_check(["git", "rev-parse", "--git-dir"]).strip()
    import os
    return any(
        os.path.exists(f"{git_dir}/{d}")
        for d in ("rebase-merge", "rebase-apply")
    )


def claude_resolve(conflicts: list[str], base: str) -> bool:
    files_arg = " ".join(conflicts)
    prompt = f"""You are inside a git rebase onto {base}. The following files have merge conflicts:

{files_arg}

For each file:
1. Read the file and identify the <<<<<<< / ======= / >>>>>>> conflict markers.
2. Resolve each conflict. The HEAD side is the commit being replayed; the incoming side is what's already on {base}. Prefer keeping the intent of the commit being replayed unless it's clearly stale.
3. Remove all conflict markers.
4. Do NOT run `git add` or `git rebase --continue` — just leave the files in a resolved state.

You are allowed to do some basic commands like `task generate` or any read
operations. You are not allowed to run any git commands except for `git rebase
continue`.

If a conflict is genuinely ambiguous (semantic, not just textual), leave the markers in place for that hunk and explain why at the end."""

    r = run([
        "claude",
        "-p", prompt,
        "--permission-mode", "bypassPermissions",
        "--allowed-tools",
            "Read",
            "Edit",
            "Glob",
            "Grep",
            "Bash(task generate)",
            "Bash(git rebase --continue)",
            "Bash(git status)",
            "Bash(git diff:*)",
        "--disallowed-tools",
            "Bash(git add:*)",
            "Bash(git commit:*)",
            "Bash(git checkout:*)",
            "Bash(git reset:*)",
            "Bash(git push:*)",
            "Bash(git rebase --abort)",
            "Bash(git rebase --skip)",
            "Write",
    ])
    return r.returncode == 0


def push(force: bool) -> int:
    branch = current_branch()
    cmd = (
        ["git", "push", "--force-with-lease"]
        if force
        else ["git", "push", "-u", "origin", branch]
    )
    print(f"==> {' '.join(cmd)}", file=sys.stderr)
    r = run(cmd)
    if r.returncode != 0 and not force:
        return push(force=True)
    return r.returncode


def get_diff(base: str) -> str:
    log = run_check(["git", "log", f"{base}..HEAD", "--oneline"])
    stat = run_check(["git", "diff", "--stat", f"{base}...HEAD"])
    diff = run_check(["git", "diff", f"{base}...HEAD"])
    out = f"## Commits\n{log}\n## Stat\n{stat}\n## Diff\n{diff}"
    if len(out) > MAX_DIFF_CHARS:
        out = out[:MAX_DIFF_CHARS] + "\n\n[...truncated...]"
    return out


# --- gh ------------------------------------------------------------------

def get_pr() -> dict | None:
    branch = current_branch()
    r = run(
        ["gh", "pr", "view", branch, "--json", "number,body,url"],
        capture_output=True,
    )
    if r.returncode != 0:
        return None
    return json.loads(r.stdout)


def create_pr(base: str, title: str, body: str) -> int:
    print(f"==> gh pr create --base {base} --title {title!r}", file=sys.stderr)
    return run(
        ["gh", "pr", "create", "--base", base, "--title", title, "--body", body]
    ).returncode


def update_pr_body(pr_number: int, body: str) -> int:
    return run(["gh", "pr", "edit", str(pr_number), "--body", body]).returncode


# --- linear --------------------------------------------------------------

def linear(api_key: str, query: str, variables: dict | None = None) -> dict:
    r = httpx.post(
        LINEAR_API,
        headers={"Authorization": api_key, "Content-Type": "application/json"},
        json={"query": query, "variables": variables or {}},
        timeout=30,
    )
    r.raise_for_status()
    body = r.json()
    if "errors" in body:
        sys.stderr.write(f"Linear API errors: {json.dumps(body['errors'], indent=2)}\n")
        sys.exit(1)
    return body["data"]


def fetch_open_issues(ro_key: str, team_keys: list[str]) -> list[dict]:
    data = linear(
        ro_key,
        """
        query MyIssues($teams: [String!]!) {
          issues(
            first: 100,
            filter: {
              assignee: { isMe: { eq: true } },
              team: { key: { in: $teams } },
              state: { type: { nin: ["completed", "canceled"] } }
            },
            orderBy: updatedAt
          ) {
            nodes { id identifier title description url }
          }
        }
        """,
        {"teams": team_keys},
    )
    return data["issues"]["nodes"]


def get_team_id(ro_key: str, team_key: str) -> str:
    data = linear(
        ro_key,
        "query($k: String!) { teams(filter: { key: { eq: $k } }) { nodes { id } } }",
        {"k": team_key},
    )
    nodes = data["teams"]["nodes"]
    if not nodes:
        sys.exit(f"g_s: no Linear team with key {team_key}")
    return nodes[0]["id"]


def get_my_user_id(ro_key: str) -> str:
    return linear(ro_key, "query { viewer { id } }")["viewer"]["id"]


def create_linear_issue(
    wro_key: str, team_id: str, assignee_id: str, title: str, description: str
) -> dict:
    data = linear(
        wro_key,
        """
        mutation($input: IssueCreateInput!) {
          issueCreate(input: $input) {
            success
            issue { id identifier url title }
          }
        }
        """,
        {
            "input": {
                "teamId": team_id,
                "assigneeId": assignee_id,
                "title": title,
                "description": description,
            }
        },
    )
    payload = data["issueCreate"]
    if not payload["success"]:
        sys.exit("g_s: Linear issueCreate returned success=false")
    return payload["issue"]

# --- claude --------------------------------------------------------------

def claude_match_issue(
    diff: str, issues: list[dict], anthropic_key: str
) -> dict | None:
    if not issues:
        return None
    catalog = "\n".join(
        f"- {i['identifier']}: {i['title']}\n  {(i.get('description') or '')[:300]}"
        for i in issues
    )
    tool = {
        "name": "select_issue",
        "description": "Pick the matching Linear issue, or empty if none fit.",
        "input_schema": {
            "type": "object",
            "properties": {
                "identifier": {
                    "type": "string",
                    "description": (
                        f"Identifier (e.g. {TEAM_KEYS[0]}-42) of the matching issue. "
                        "Empty string if no issue clearly matches the diff."
                    ),
                },
                "reasoning": {"type": "string"},
            },
            "required": ["identifier", "reasoning"],
        },
    }
    client = anthropic.Anthropic(api_key=anthropic_key)
    resp = client.messages.create(
        model=MODEL,
        max_tokens=512,
        tools=[tool],
        tool_choice={"type": "tool", "name": "select_issue"},
        messages=[
            {
                "role": "user",
                "content": (
                    "Pick the Linear issue most relevant to this diff, or return "
                    "an empty identifier if none clearly fit. Be conservative.\n\n"
                    f"## Open issues\n{catalog}\n\n## Diff\n{diff}"
                ),
            }
        ],
    )
    for block in resp.content:
        if block.type == "tool_use":
            ident = block.input.get("identifier", "").strip()
            for issue in issues:
                if issue["identifier"] == ident:
                    return issue
            return None
    return None


def claude_summarize_pr(diff: str, anthropic_key: str) -> dict:
    tool = {
        "name": "create_pr",
        "description": "Generate PR title, description, and type from a diff.",
        "input_schema": {
            "type": "object",
            "properties": {
                "pr_name": {
                    "type": "string",
                    "description": (
                        "Concise PR title describing what changed. No prefix, "
                        "no ticket number, no trailing period. ~80 chars max."
                    ),
                },
                "pr_description": {
                    "type": "string",
                    "description": (
                        "PR description, 100 words or less. Plain prose, no "
                        "markdown headings or bullet lists. Explain what "
                        "changed and why."
                    ),
                },
                "pr_type": {
                    "type": "string",
                    "enum": ["feat", "chore"],
                },
            },
            "required": ["pr_name", "pr_description", "pr_type"],
        },
    }
    client = anthropic.Anthropic(api_key=anthropic_key)
    resp = client.messages.create(
        model=MODEL,
        max_tokens=1024,
        tools=[tool],
        tool_choice={"type": "tool", "name": "create_pr"},
        messages=[
            {
                "role": "user",
                "content": (
                    "Generate PR metadata for the diff below. Description must "
                    "be 100 words or less, plain prose, no headings or bullets.\n\n"
                    f"{diff}"
                ),
            }
        ],
    )
    for block in resp.content:
        if block.type == "tool_use":
            return block.input
    sys.exit("g_s: Claude returned no tool_use block")


def claude_draft_issue(diff: str, anthropic_key: str) -> dict:
    tool = {
        "name": "draft_issue",
        "input_schema": {
            "type": "object",
            "properties": {
                "title": {"type": "string"},
                "description": {"type": "string"},
            },
            "required": ["title", "description"],
        },
    }
    client = anthropic.Anthropic(api_key=anthropic_key)
    resp = client.messages.create(
        model=MODEL,
        max_tokens=512,
        tools=[tool],
        tool_choice={"type": "tool", "name": "draft_issue"},
        messages=[
            {
                "role": "user",
                "content": (
                    "Draft a Linear issue title (concise) and description "
                    "(100 words max, plain prose, no markdown headings) "
                    f"for this diff:\n\n{diff}"
                ),
            }
        ],
    )
    for block in resp.content:
        if block.type == "tool_use":
            return block.input
    sys.exit("g_s: Claude returned no tool_use block")


# --- orchestration -------------------------------------------------------

def find_or_create_linear(diff: str, ro_key: str, wro_key: str, anthropic_key: str) -> dict:
    print(
        f"==> Fetching open {'/'.join(TEAM_KEYS)} issues assigned to you...",
        file=sys.stderr,
    )
    issues = fetch_open_issues(ro_key, TEAM_KEYS)

    print("==> Matching diff against open issues...", file=sys.stderr)
    matched = claude_match_issue(diff, issues, anthropic_key)
    if matched:
        print(f"==> Matched {matched['identifier']}: {matched['title']}")
        return matched

    print("==> No match. Drafting new issue...", file=sys.stderr)
    draft = claude_draft_issue(diff, anthropic_key)
    print()
    print(f"  title: {draft['title']}")
    print(f"  desc:  {draft['description']}")
    print()
    if input("Create this issue? [Y/n] ").strip().lower() not in {"", "y", "yes"}:
        sys.exit(1)
    team_id = get_team_id(ro_key, TEAM_KEYS[0])
    user_id = get_my_user_id(ro_key)
    issue = create_linear_issue(
        wro_key, team_id, user_id, draft["title"], draft["description"]
    )
    print(f"==> Created {issue['identifier']}: {issue['url']}")
    return issue


def body_with_linear(body: str, identifier: str, url: str) -> str:
    body = body or ""
    if identifier in body:
        return body
    line = f"Linear: [{identifier}]({url})" if url else f"Linear: {identifier}"
    return f"{body.rstrip()}\n\n{line}\n".lstrip()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", default="main", help="Base branch (default: main)")
    args = parser.parse_args()

    for tool in ("git", "gh", "pass"):
        if not shutil.which(tool):
            sys.exit(f"g_s: {tool} not found in PATH")

    branch = current_branch()
    if branch == args.base:
        sys.exit(f"g_s: refusing to operate on base branch '{branch}'")

    pr = get_pr()
    rebase(args.base)

    if run_check(["git", "diff", f"{args.base}...HEAD"]).strip() == "":
        sys.exit("g_s: no diff against base, nothing to do")

    diff = get_diff(args.base)
    ro_key = pass_get("linear/porter/ro")
    wro_key = pass_get("linear/porter/wro-gil")
    anthropic_key = pass_get("ai/anthropic/porter")

    issue = find_or_create_linear(diff, ro_key, wro_key, anthropic_key)
    identifier = issue["identifier"]
    issue_url = issue.get("url", "")
    issue_number = identifier.split("-", 1)[1]

    if pr is not None:
        print("==> Existing PR — pushing and ensuring Linear reference", file=sys.stderr)
        if push(force=True) != 0:
            return 1
        new_body = body_with_linear(pr.get("body") or "", identifier, issue_url)
        if new_body != (pr.get("body") or ""):
            return update_pr_body(pr["number"], new_body)
        return 0

    print("==> No PR — generating PR metadata", file=sys.stderr)
    meta = claude_summarize_pr(diff, anthropic_key)
    print()
    print(f"  type: {meta['pr_type']}")
    print(f"  name: {meta['pr_name']}")
    print(f"  desc: {meta['pr_description']}")
    print()

    team_prefix = identifier.split("-", 1)[0]
    title = f"{meta['pr_type']}: [{team_prefix} - {issue_number}] {meta['pr_name']}"
    body = body_with_linear(meta["pr_description"], identifier, issue_url)

    if push(force=False) != 0:
        return 1
    return create_pr(args.base, title, body)


if __name__ == "__main__":
    sys.exit(main())
