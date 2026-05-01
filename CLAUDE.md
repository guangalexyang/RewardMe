# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**RewardMe** is a family points-management iOS app. Parents award points to children for completing daily activities (piano practice, homework, sports, etc.) and children redeem those points for rewards according to parent-defined rules.

## Domain Model

### Core Concepts

**Child** — a tracked family member with a running point balance and a history of point changes.

**Event** — a logged point transaction tied to a child. Each event records:
- `delta` (positive = earned, negative = spent/removed)
- `timestamp`
- a reference to the **Rule** that caused it (the "category")
- optional free-text note

**Rule** — a parent-defined policy that acts as both a category for grouping events and a redemption definition. A rule has two independent, optional dimensions:

**1. Point change on redemption** (`pointCostPerUnit: Int?`, `unitLabel: String?`)
- If set, redeeming deducts points from the child's balance.
- Can be a fixed cost (e.g. "costs 10 pts") or a per-unit rate (e.g. "1 pt per $1 spent on Lego").
- `unitLabel` gives the unit human-readable meaning ("dollar", "minute", etc.).
- If `nil`, redeeming this rule does not change the point balance.

**2. Threshold that must be met to unlock the reward** (`thresholdAmount: Int?`, `thresholdPeriod: ThresholdPeriod?`)
- If set, the child must have accumulated at least `thresholdAmount` points within `thresholdPeriod` (`daily` / `weekly` / `monthly` / `yearly`) before a redemption is allowed.
- Threshold checks look at *earned* event deltas within the period, not the total balance.
- If `nil`, no threshold guard — redemption is allowed as long as the balance covers the cost (if any).

These two dimensions are independent; a rule can have both, either, or neither:

| Example rule | pointCostPerUnit | thresholdAmount / period |
|---|---|---|
| 1 pt = $1 Lego purchase | 1 pt / $1 | — |
| Screen time (≥ 6 pts today) | — (no cost) | 6 / daily |
| Weekend outing (≥ 25 pts/week) | — (no cost) | 25 / weekly |
| Premium toy (earn 50/month, costs 20 pts) | 20 pts fixed | 50 / monthly |

When a redemption is submitted, the app reads the rule and automatically:
1. Checks the threshold (if configured) — blocks if not met.
2. Deducts points (if `pointCostPerUnit` is set) by writing a negative `PointEvent` linked to this rule.

**Redemption** — the act of applying a rule for a child. Creates a `Redemption` record and, if the rule has a point cost, a corresponding negative `PointEvent` automatically.

### Key Invariants
- Point balance is the sum of all event deltas for a child (never stored separately — computed or cached).
- A rule deletion should soft-delete (archive) so historical events retain their category reference.

## Planned Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| UI | SwiftUI | Targets iOS 17+; Watch port uses the same paradigm |
| Local DB (phase 1) | SwiftData | Lightweight, native, no server needed initially |
| Backend DB (phase 4+) | TBD (e.g. PostgreSQL) | Hosted on fly.io |
| Backend API (phase 4+) | TBD (e.g. Vapor or Node) | REST or GraphQL, hosted on fly.io |
| AI/Voice | App Intents + SiriKit | Enables Siri and future Doubao integration |
| Watch | watchOS companion app | Shares models via App Group / Swift Package |
| Architecture | MVVM + `@Observable` | Keeps SwiftUI previews fast and testable |

## Architecture

```
RewardMe/
├── RewardMeApp.swift          # App entry point, ModelContainer setup
├── Models/                    # SwiftData @Model classes
│   ├── Child.swift
│   ├── Rule.swift
│   ├── PointEvent.swift
│   └── Redemption.swift
├── ViewModels/                # @Observable view-model layer
├── Views/                     # SwiftUI screens
│   ├── Dashboard/             # Per-child point summary + trend charts
│   ├── Events/                # Log and browse point events
│   ├── Rules/                 # CRUD for rules
│   └── Redemption/            # Redeem flow
├── Intents/                   # App Intents for Siri integration
└── RewardMeWatch/             # watchOS target (added later)
```

### Data flow (Phase 1)
Views → ViewModels → SwiftData `ModelContext` → SQLite on-device. No network layer.

### Data flow (Phase 4+)
The local SwiftData store acts as a write-ahead cache; a sync layer pushes/pulls from the fly.io backend API. The backend becomes the source of truth for multi-device families.

### SwiftData container
`ModelContainer` is configured at app launch with the full schema (`Child`, `Rule`, `PointEvent`, `Redemption`). Injected via `.modelContainer(for:)` and accessed in views with `@Environment(\.modelContext)`.

## Siri / App Intents

Each user-facing action that makes sense as a voice command gets its own `AppIntent` struct. Planned intents:
- `AwardPointsIntent` — "Award 3 points to Lily for piano"
- `CheckBalanceIntent` — "What's Lily's point balance?"
- `RedeemRewardIntent` — "Redeem screen time for Lily"

Intents live in `Intents/` and are registered in `AppIntentsPackage`. Doubao integration will call the same underlying service layer as Siri intents.

## Development Phases

1. **Phase 1 (current)** — iOS app, SwiftData local DB, full CRUD for children/rules/events, dashboard with Charts.
2. **Phase 2** — App Intents / Siri integration; Doubao API hook-in.
3. **Phase 3** — Apple Watch companion app (read balance, quick award).
4. **Phase 4** — Backend server on fly.io (PostgreSQL + API); iCloud or server-based sync for multi-device families.

## Xcode Project Setup

- Minimum deployment target: **iOS 17.0** (required for SwiftData + `@Observable`)
- Swift 5.10+
- Enable *App Groups* entitlement from phase 3 onward (Watch data sharing)
- Charts framework is bundled in iOS 16+; no extra SPM dependency needed for basic trend charts

## Common Commands

```bash
# Build (adjust scheme/destination as needed)
xcodebuild -scheme RewardMe -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -scheme RewardMe -destination 'platform=iOS Simulator,name=iPhone 16' test

# Open in Xcode
open RewardMe.xcodeproj
```
