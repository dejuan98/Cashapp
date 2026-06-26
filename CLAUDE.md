# Project Context Document: CashappSpoof (dejuan98/Cashapp)

## Project Overview

CashappSpoof is an iOS application built with Swift that simulates the Cash App user interface. The application appears to be a "spoof" or replica of the Cash App payment platform, designed to mimic the look and feel of real Cash App transaction screens including balance displays, payment sending flows, activity logs, and success/result screens.

> ⚠️ **Note:** This project replicates a financial application's UI. It is likely intended for demonstration, prank, or educational purposes and does not perform real financial transactions.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift |
| UI Framework | UIKit (Storyboard-based) |
| Project Format | Xcode Project (`.xcodeproj`) |
| Minimum Target | iOS (version inferred from project structure) |
| Interface Builder | Main.storyboard + LaunchScreen.storyboard |
| Asset Management | Xcode Asset Catalogs (`.xcassets`) |
| Architecture | MVC (Model-View-Controller) |

---

## Architecture

The project follows a standard **MVC (Model-View-Controller)** pattern typical of UIKit-based iOS applications.

```
CashappSpoof/
├── Model
│   └── DataManager.swift          # Central data/state management
├── Views
│   ├── Main.storyboard            # Primary UI layout
│   ├── LaunchScreen.storyboard    # App launch screen
│   ├── ActivityCell.swift         # Custom UITableViewCell
│   └── Assets.xcassets/           # Images and colors
└── Controllers
    ├── AppDelegate.swift           # App lifecycle
    ├── SceneDelegate.swift         # Scene lifecycle (iOS 13+)
    ├── ViewController.swift        # Root/Home screen
    ├── BalanceViewController.swift # Balance display screen
    ├── SendViewController.swift    # Payment send flow
    ├── LoadingViewController.swift # Loading/transition screen
    ├── SuccessViewController.swift # Payment success screen (animated checkmark)
    ├── ResultViewController.swift  # Transaction result screen
    ├── ActivityViewController.swift# Transaction activity list
    └── ActivityDetailViewController.swift # Detail view for activity
```

### Application Flow

```
Launch Screen
    └── ViewController (Home)
            ├── BalanceViewController    → Displays spoofed balance
            ├── SendViewController       → Initiates fake payment
            │       └── LoadingViewController  → Simulated processing
            │               └── SuccessViewController → Payment confirmed (animated checkmark)
            │                       └── ResultViewController → Final result
            └── ActivityViewController  → Transaction history list
                    └── ActivityDetailViewController → Single transaction detail
```

---

## Key Files

### `AppDelegate.swift`
- Standard iOS app entry point
- Handles application lifecycle events (`didFinishLaunchingWithOptions`, background/foreground transitions)
- Configures the initial app window (pre-iOS 13 fallback)

### `SceneDelegate.swift`
- Manages the app's UI scene lifecycle for iOS 13+
- Handles scene connection, disconnection, and state restoration

### `ViewController.swift`
- Root/home view controller
- Likely serves as the landing screen mimicking the Cash App home screen
- Entry point for navigation to other screens

### `DataManager.swift`
- Central data management class
- Likely stores and provides access to spoofed data: user name, balance, transaction history, recipient information
- Possibly implemented as a singleton for global access across view controllers
- Manages state shared between screens (e.g., amount entered, recipient $cashtag)

### `SendViewController.swift`
- Handles the payment send UI flow
- Captures user input: payment amount and recipient details
- Triggers navigation to the loading/success screens

### `LoadingViewController.swift`
- Simulates a payment processing screen with animation or activity indicator
- Uses a timed delay (likely `DispatchQueue.main.asyncAfter`) to transition to the success screen

### `SuccessViewController.swift`
- Displays the payment success confirmation screen
- Implements a **programmatic animated Cash App-style checkmark** drawn using `CAShapeLayer` and `CABasicAnimation`
- Animation sequence:
  - A circular background layer animates in (stroke draw-on effect)
  - A checkmark path animates in after the circle completes, using `strokeEnd` animation
  - Timing uses `CABasicAnimation` with sequential `beginTime` offsets or completion callbacks
- The checkmark and circle are drawn in code (not image-based), using `UIBezierPath`
- Animation is triggered in `viewDidAppear(_:)` to ensure the view is visible before animating
- Uses `CAShapeLayer` properties: `strokeColor`, `fillColor`, `lineWidth`, `lineCap`, `strokeEnd`

### `ResultViewController.swift`
- Shows the final transaction result
- May display a receipt-style view with sender, recipient, amount, and timestamp

### `BalanceViewController.swift`
- Displays a spoofed account balance screen
- Reads balance data likely from `DataManager`

### `ActivityViewController.swift`
- Lists historical (fake) transactions using a `UITableView`
- Uses `ActivityCell` as its custom cell

### `ActivityCell.swift`
- Custom `UITableViewCell` subclass
- Renders individual transaction rows with relevant data (name, amount, date)

### `ActivityDetailViewController.swift`
- Shows a detailed view of a single activity/transaction
- Receives data passed from `ActivityViewController` via segue or direct property injection

### `ImageViewExtension.swift`
- Utility extension on `UIImageView`
- Likely adds helper methods such as circular masking, corner rounding, or async image loading

---

## Asset Catalog (`Assets.xcassets`)

| Asset Name | Purpose |
|---|---|
| `AppIcon` | Application icon |
| `AccentColor` | App-wide accent/tint color |
| `Square_Cash_app_logo` | Cash App logo image |
| `activity` | Icon for the activity tab/button |
| `balance` | Icon/image for balance screen |
| `cashappsend` | Image for send payment flow |
| `finished` | Image shown on completion screen |
| `homebackground` | Background image for home screen |
| `sent` | Confirmation image shown after sending |

---

## Coding Conventions

Based on standard Swift/UIKit patterns inferred from the project structure:

### Naming
- **View Controllers**: PascalCase with `ViewController` suffix (e.g., `SendViewController`, `ResultViewController`)
- **Custom Cells**: PascalCase with `Cell` suffix (e.g., `ActivityCell`)
- **Extensions**: Descriptive PascalCase (e.g., `ImageViewExtension`)
- **Swift files**: One primary class/struct per file, filename matches type name

### Patterns
- **Storyboard-driven UI**: Primary layout defined in `Main.storyboard` with segues connecting view controllers
- **MVC separation**: Data logic isolated in `DataManager`, display logic in view controllers
- **Singleton pattern**: `DataManager` likely uses a shared instance pattern:
  ```swift
  class DataManager {
      static let shared = DataManager()
      private init() {}
  }
  ```
- **Data passing**: Between view controllers likely via `prepare(for:sender:)` segue method or direct property assignment

### UI Construction
- Storyboard + Auto Layout for interface design
- `IBOutlet` and `IBAction` connections from storyboard
- `UITableView` with custom cells for list displays
- **Programmatic `CAShapeLayer` animation** used in `SuccessViewController` for the checkmark (not storyboard-based)

### Animation Conventions
- **Framework**: `CoreAnimation` (`CAShapeLayer`, `CABasicAnimation`) — no third-party animation libraries
- **Trigger point**: Animations started in `viewDidAppear(_:)`, not `viewDidLoad`
- **Drawing**: Shapes drawn with `UIBezierPath`; layers added as sublayers to `view.layer`
- **Stroke animation**: `strokeEnd` keyPath used for draw-on line effects
- **Sequencing**: Sequential animations achieved via `beginTime` offsets (`CACurrentMediaTime() + delay`) or `CAAnimationGroup`
- **Fill mode**: `fillMode = .forwards` and `isRemovedOnCompletion = false` used to preserve end state of animations

---

## Development Workflow

### Project Setup
1. Clone the repository
2. Open `CashappSpoof.xcodeproj` in Xcode
3. Select a simulator or connected device
4. Build and run (`Cmd+R`)

> No external package managers (CocoaPods, SPM, Carthage) are detected — the project appears to use only Apple frameworks.

### Key Developer Info
- **Original Developer Username**: `ethankeiser` (inferred from `xcuserdata` directory)
- **Breakpoints File**: Present at `xcuserdata/ethankeiser.xcuserdatad/xcdebugger/Breakpoints_v2.xcbkptlist`
- **Scheme Management**: Custom scheme settings stored in `xcschememanagement.plist`

### File Count Summary
- **Total Files**: 32
- **Swift Source Files**: ~14 view controllers + support files
- **Storyboard Files**: 2 (Main + LaunchScreen)
- **Asset Files**: Multiple image sets within `.xcassets`
- **Configuration**: `Info.plist`, `.xcodeproj` project files

---

## Important Notes for AI Coding Assistance

1. **No external dependencies** — All code relies on native iOS/UIKit frameworks only; animations use `CoreAnimation`, not libraries like Lottie.
2. **Storyboard-centric** — UI changes should be made in `Main.storyboard`; view controllers use `@IBOutlet`/`@IBAction`. Exception: `SuccessViewController` checkmark animation is fully programmatic.
3. **DataManager is the source of truth** — Any data displayed across screens should flow through `DataManager.swift`.
4. **Navigation is likely segue-based** — Use `performSegue(withIdentifier:sender:)` and `prepare(for:sender:)` patterns.
5. **No real networking** — All transaction data is local/hardcoded or generated; there are no API calls to actual Cash App services.
6. **iOS 13+ scene lifecycle** — Both `AppDelegate` and `SceneDelegate` are present, indicating iOS 13+ multi-scene support.
7. **Function density** — With 104 functions across 32 files, average ~3.25 functions per file, suggesting relatively concise, focused view controllers.
8. **Animation pattern established** — `SuccessViewController` sets the precedent for `CAShapeLayer`/`CABasicAnimation`-based animations. Any future animated UI elements should follow this same pattern: programmatic `UIBezierPath` drawing, `strokeEnd` animation, triggered in `viewDidAppear(_:)`, with `fillMode = .forwards` and `isRemovedOnCompletion = false`.