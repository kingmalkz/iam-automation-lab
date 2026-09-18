# IAM Automation Lab

Identity and access management workflows built with n8n, Microsoft Graph, Claude Code, and Python.

Twelve projects that automate the work an IAM administrator does by hand: joiner-mover-leaver processing, access reviews, MFA gap reporting, stale account auditing, and identity posture reporting. Each one runs against a disposable Microsoft 365 test tenant with synthetic data.

**Status:** 1 of 12 complete. In progress, September to December 2026.

## Why this exists

I administer identity at a lending company: account lifecycle, access reviews, Entra ID, Microsoft 365. Most of that work is repetitive and auditable, which makes it a good fit for automation. This repository is where I build those automations properly, with approvals, error handling, audit trails, and backups, rather than as one-off scripts.

## Stack

| Layer | Choice |
|---|---|
| Orchestration | n8n 2.39.7, self-hosted with Docker Compose |
| Identity | Microsoft Graph, Entra ID app registrations with application permissions |
| Language | Python 3 (Flask, pytest) for logic that doesn't belong in a workflow |
| AI | Claude (Haiku) for classification and summarisation, Claude Code for building and review |
| Data | PostgreSQL for audit trails and snapshots, Google Sheets for lightweight config and reports |
| Host | Ubuntu on WSL2, Docker Engine |

## Projects

### Beginner

| # | Project | What it does | Status |
|---|---|---|---|
| B1 | Local stack and first webhook | n8n stack hardened with restart policies and a localhost-only port binding; HTTP-triggered workflow; versioned exports | Done |
| B2 | KEV security digest | Daily email of vulnerabilities newly added to the CISA Known Exploited Vulnerabilities catalog | Planned |
| B3 | Access request intake | Self-service form with a justification control, logged to a sheet, with requester notifications | Planned |
| B4 | AI ticket triage | Classifies identity tickets into category, priority, and a security flag, scored against a fixed evaluation set | Planned |
| B5 | MFA methods report | Reads every user's registered authentication methods through Graph and reports accounts with no MFA | Planned |
| B6 | Stale account auditor | Tested Python service that flags enabled accounts inactive beyond a threshold, called from a workflow | Planned |

### Experienced

| # | Project | What it does | Status |
|---|---|---|---|
| E1 | Joiner automation | Creates the account, assigns groups by department, sets the manager, behind a manager approval and a duplicate check | Planned |
| E2 | Access review | Monthly per-group review sent to owners, responses validated and logged, reviews run independently | Planned |
| E3 | IAM helpdesk agent | Chat agent answering identity questions through read-only tools, tested against prompt injection | Planned |
| E4 | Production hardening | SQLite to PostgreSQL migration with credentials intact, backups with a restore test, retries, runbook | Planned |

### Expert

| # | Project | What it does | Status |
|---|---|---|---|
| X1 | Full JML lifecycle | Joiner, mover, and leaver paths with approvals, pre-checks for safe re-runs, rollback rules, and a tamper-resistant audit trail | Planned |
| X2 | Identity posture digest | Weekly report for small tenants covering MFA gaps, stale accounts, guests, and admin role holders, with a plain-English summary | Planned |

## Repository layout

```
.
├── workflows/     exported n8n workflow JSON, one file per workflow
├── auditor/       Python service (B6): Flask API, pure logic module, pytest suite, Dockerfile
├── infra/         compose.override.yml for the n8n stack, symlinked into the stack folder
├── scripts/       workflow export and database backup
├── docs/          project notes, designs, test results, credential inventory, runbook
├── CLAUDE.md      working rules for Claude Code in this repository
└── README.md
```

Workflow JSON references credentials by name and ID. It contains no secret values.

## Design rules

**Test tenant only.** No employer tenant, data, or credentials appear anywhere in this repository. User data is synthetic and generated with a fixed seed.

**Least privilege, split by function.** Read-only reporting uses one Entra app registration; write operations for lifecycle automation use a separate one. Every permission is justified in `docs/`.

**Check before acting.** Lifecycle steps read current state before changing it, so a re-run is a no-op rather than a duplicate or an error.

**Fail safe.** A joiner that fails partway is rolled back to a disabled account. A leaver that fails partway is never re-enabled automatically; a human is alerted.

**Audit outside the tool.** Lifecycle changes are written to an append-only PostgreSQL table, so what happened can be explained without opening n8n.

**Data minimisation.** The AI summarisation step receives counts and categories, never names or user principal names.

**Secrets stay in the credential store.** Never in Git, never in prompts, never in environment variables that workflow expressions can read.

## Running it

This repository holds workflows, scripts, and configuration, not a turnkey deployment. Reproducing it needs an n8n instance, a Microsoft 365 test tenant with your own app registrations, and your own credentials.

```bash
# export workflows from the running n8n container into ./workflows
./scripts/export-workflows.sh

# back up the n8n database (after E4)
./scripts/backup.sh

# run the auditor service tests (B6)
cd auditor && python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt && pytest -q
```

Import a workflow by opening n8n, creating a workflow, and pasting the JSON from `workflows/`. You then select your own credentials on each node.

## Notes

Built alongside a full-time IAM role. Each project includes what it does, the permissions it uses, and how it was tested. Where something is deliberately out of scope, the roadmap says so rather than pretending otherwise.
