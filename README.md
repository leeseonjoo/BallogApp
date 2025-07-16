# BallogApp

BallogApp is a small SwiftUI experiment structured with the MVVM (Model–View–ViewModel) pattern.

The app now stores user sign-up information using **Firebase Firestore** via helpers in `Utilities/FirestoreAccountService.swift`.

## Design Philosophy

The UI follows the core principles described in Apple’s Human Interface Guidelines:

1. **Clarity** – Text and controls use system fonts and default sizes to stay legible and familiar.
2. **Deference** – Content is prioritized over decoration by keeping layouts simple and spacing consistent.
3. **Depth** – Hierarchy is communicated through clean navigation stacks and unobtrusive transitions.

## Folder Structure

- `Ballog/App` - Application entry point
- `Ballog/Models` - Model types
- `Ballog/Utilities` - Helper utilities including Firebase services
- `Ballog/ViewModels` - ViewModel logic (currently empty)
- `Ballog/Views` - SwiftUI views
- `Ballog/Assets.xcassets` - Assets used by the app
- `Ballog/Ballog.entitlements` - App entitlements

