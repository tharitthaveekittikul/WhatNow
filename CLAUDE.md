# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WhatNow is an iOS decision-helper app built with SwiftUI that helps users decide what to eat or what activity to do using a slot-machine style random picker. The app fetches data from a backend API and displays restaurants from various malls in Thailand.

**App Display Name**: "WhatNow: อะไรดี" (Thai for "What's good?")

## Build Configuration

- **Xcode Project**: `WhatNow.xcodeproj`
- **Target**: WhatNow
- **Minimum iOS Deployment**: 16.6
- **Swift Version**: 5.0
- **Development Team ID**: 3V32V63Z66
- **Bundle Identifier**: com.cloudy.WhatNow
- **Current Version**: 1.0

## Building and Running

```bash
# Open in Xcode
open WhatNow.xcodeproj

# Build from command line
xcodebuild -project WhatNow.xcodeproj -scheme WhatNow -configuration Debug build

# Build for simulator
xcodebuild -project WhatNow.xcodeproj -scheme WhatNow -configuration Debug -sdk iphonesimulator build
```

## Architecture

This project follows **Clean Architecture** with **MVVM + Use Cases** pattern:

### Layer Structure

```
WhatNow/
├── DesignSystem/           # Design tokens and reusable components
│   ├── Colors/            # Color tokens (Cloudy theme)
│   ├── Typography/        # SF Pro Rounded typography
│   └── Components/        # Reusable UI components
├── Core/
│   ├── Domain/            # Business logic layer
│   │   ├── Models/        # Domain entities
│   │   ├── Protocols/     # Service interfaces
│   │   └── UseCases/      # Business use cases
│   └── Infrastructure/    # Implementation layer
│       ├── Networking/    # API service implementations
│       └── DependencyContainer.swift
└── Features/              # Feature modules
    ├── Home/             # Home screen
    ├── Category/         # Category selection
    ├── Mall/             # Mall selection
    └── Spin/             # Spinning reel picker
```

### Key Principles

- **Single Source of Truth**: ViewModels hold state
- **Dependency Injection**: Via DependencyContainer
- **Protocol-Oriented**: Services defined as protocols
- **Separation of Concerns**: Domain, Infrastructure, Presentation
- **SwiftUI Best Practices**: Using @StateObject, @Published, async/await

## Design System

### Cloudy Theme Colors

**Light Mode:**
- Background: CloudyLight (#F4F7FB), CloudyPrimary (#E6EBF2)
- Surface: SurfacePrimary (#FFFFFF), SurfaceSoft (#EEF2F7)
- Accents: AccentWarm (#FFE6C7), AccentSky (#DDEBFF), AccentLavender (#EDE7F6)
- Text: TextPrimary (#2B3440), TextSecondary (#6B7280), TextTertiary (#9CA3AF)

**Dark Mode:**
- Background: CloudyLightDark (#1E2430), CloudyPrimaryDark (#252C3A)
- Surface: SurfacePrimaryDark (#1B202B), SurfaceSoftDark (#242B38)
- Accents: AccentWarmDark (#5A4630), AccentSkyDark (#3A4C6A), AccentLavenderDark (#4A3F5E)
- Text: TextPrimaryDark (#E5E9F0), TextSecondaryDark (#B6BDC9), TextTertiaryDark (#8A93A3)

**Usage:** Use semantic colors like `Color.App.background`, `Color.App.text`

### Typography

- **Typeface**: SF Pro Rounded (system rounded design)
- **Dynamic Type**: Supported
- **Semantic Styles**: `.appLargeTitle`, `.appTitle`, `.appHeadline`, `.appBody`, etc.
- **Text Modifiers**: `.titleStyle()`, `.bodyStyle()`, `.secondaryStyle()`

## Backend API

**Base URL**: `https://whatnow-api-867193034636.asia-southeast1.run.app`

### Endpoints

- `GET /v1/packs/malls/index` - Get list of malls
- `GET /v1/packs/malls/:mallId` - Get stores for specific mall

### Response Structure

```swift
// Malls Index
{ version, updatedAt, malls: [Mall] }

// Mall Pack
{ version, updatedAt, mall: Mall, taxonomy: Taxonomy, categories: [StoreCategory] }

// Store
{ id, name: {th, en}, displayName, tags: [String], priceRange: "budget"|"mid"|"premium" }
```

## App Flow

1. **HomeView**: User selects "กินอะไรดี" (What to eat) or "ทำอะไรดี" (What to do)
2. **FoodCategoryView**: User selects "ร้านในห้าง" (Mall) or "ร้านดัง" (Famous Store)
3. **MallSelectionView**: User selects a mall (fetches from API)
4. **SpinView**: Displays slot-machine reel picker with spin animation

## Key Components

### ReelPicker
Slot-machine style vertical picker with:
- 5 visible rows
- Center highlight bar
- Gradient fade on top/bottom
- Scale and opacity effects for depth
- Infinite looping

### Spin Animation
- Fast start (0.3s easeInOut)
- Slow deceleration (2.5s easeOut)
- Haptic feedback on completion
- Random target selection

## SwiftUI Conventions

- Use `@StateObject` for ViewModels
- Use `@Published` for observable properties
- All ViewModels marked with `@MainActor`
- Use `async/await` for asynchronous operations
- Include `#Preview` for all views
- Use `.task` for view lifecycle async work

## Dependency Injection

Access dependencies via `DependencyContainer.shared`:

```swift
let packsService = DependencyContainer.shared.packsService
let fetchMallsUseCase = DependencyContainer.shared.fetchMallsUseCase
```

## Build Settings

- **Previews**: Enabled
- **String Catalog**: Symbol generation enabled
- **Actor Isolation**: MainActor by default
- **Concurrency**: Approachable concurrency enabled
- **Orientations**: Portrait, Landscape (iPhone); All (iPad)
