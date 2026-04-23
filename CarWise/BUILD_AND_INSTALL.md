# CarWise — Build & Install

A SwiftUI iOS app. MVVM. No network. All logic runs locally against an embedded car catalog.

## Requirements

- **macOS** with Xcode 15+ (iOS 17 SDK or newer)
- **[xcodegen](https://github.com/yonaskolb/XcodeGen)** (`brew install xcodegen`) — or generate the project by hand

## Quick start

```bash
cd CarWise
xcodegen generate
open CarWise.xcodeproj
```

Select an iPhone simulator (iPhone 15 or later) and hit **⌘R**.

## Project layout

```
CarWise/
├── project.yml                 # xcodegen config → CarWise.xcodeproj
└── CarWise/
    ├── App/
    │   └── CarWiseApp.swift    # @main entry, appearance setup
    ├── Models/                 # UserProfile, Car, Recommendation, Booking, ChatMessage
    ├── Services/               # MockCarDatabase, Recommendation engine, Chat, Persistence, Notifications
    ├── ViewModels/             # AppState + per-feature VMs
    ├── Theme/                  # Colors, fonts, metrics, modifiers
    ├── Views/
    │   ├── RootView.swift      # Onboarding or TabView
    │   ├── Onboarding/
    │   ├── Home/
    │   ├── Recommendations/
    │   ├── Chat/
    │   ├── Saved/
    │   ├── Expert/
    │   └── Components/         # CarCard, Chip, ScoreRing, PrimaryButton, FlowLayout
    └── Resources/
        ├── Info.plist
        └── Assets.xcassets     # AccentColor (#E11D2A), AppIcon
```

## Architecture notes

- **`AppState`** is the single observable source of truth. Injected via `@EnvironmentObject`, persisted to `UserDefaults` via `PersistenceService`.
- **`RecommendationEngine`** is a pure struct: `(UserProfile) → [Recommendation]`. Swap target for an LLM-assisted ranker later.
- **`ChatService`** classifies intent over the user's text and composes grounded replies from `MockCarDatabase` + the profile. Swap target: LLM call with the profile as system context.
- **`MockCarDatabase`** holds ~20 cars across sedan/SUV/truck/coupe/EV/minivan. Scores per car (reliability, tech, etc.) drive the engine.

## What's included

- Multi-step onboarding (budget slider, vehicle type, condition, use cases, priorities, ownership length, brands, review)
- AI recommendation screen with match/value/confidence scores, reasoning, pros/cons
- Compare up to 3 cars side-by-side with per-row best-in-group highlighting
- Grounded chat (reliability, comparisons, budget fit, best-for queries)
- Save cars, take notes, mark top choices
- Book a simulated 30-minute consult with a calendar + slot picker
- Local notifications for "finish onboarding" and "new recommendations"

## Extending later

- Replace `ChatService.answer(...)` with an Anthropic / OpenAI call that receives the profile and the matched catalog as system context
- Add real availability via a backend (today slots are weekday-only, fixed times)
- Add StoreKit for paid consults — booking flow already has a clean seam where `vm.book()` hands off
- Replace `MockCarDatabase.all` with a server-backed catalog
