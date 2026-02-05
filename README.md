# MiniNote (iOS)

A simple SwiftUI notes app built as my first iOS development project.  
It focuses on core iOS concepts: SwiftUI state management, persistence, swipe actions, backup/restore, and a small networking feature.

## ✨ Features
- ✅ Create notes with categories (School / Work / Personal)
- 🔎 Search notes
- 🧠 Category filter chips (All / School / Work / Personal)
- 💾 Local persistence with `UserDefaults` (JSON encode/decode)
- 🧾 Summary card (Total / Visible / Today)
- 👉 Swipe actions:
  - Copy to clipboard
  - Share (Share Sheet)
  - Delete (no full-swipe to avoid accidental deletes)
- 📦 Backup & Restore:
  - Export notes to a JSON file
  - Import notes from JSON (replace or merge)
- 🌤 “Quote of the day” card (simple API fetch + cache)
- 📳 Haptic feedback for key interactions
- 🎨 Clean single-color (minimal) theme

## 🧩 Tech Stack
- **Swift**
- **SwiftUI**
- `NavigationStack`, `List`, `Section`, `sheet`, `searchable`
- Persistence: `UserDefaults` + `Codable`
- Backup/Restore: `FileDocument`, `fileExporter`, `fileImporter`
- Networking: `URLSession` + `async/await`
- iOS UX: swipe actions, share sheet, haptics

## 📱 Screens (example)
Suggested screenshots for the repo:
1. Home + Summary
2. Filter chips
3. Search results
4. Add Note (category picker)
5. Swipe actions (Copy/Share/Delete)
6. Settings (Backup/Restore)

> Add screenshots to: `Screenshots/` folder and embed them here if you want.

## 🚀 Getting Started
### Requirements
- macOS + Xcode
- iPhone simulator or a real iPhone

### Run
1. Clone the repo
2. Open `MiniNote.xcodeproj` in Xcode
3. Select a simulator (or your iPhone)
4. Press **Run (▶︎)**

## 🗂 Backup / Restore
- Open **Settings (⚙️)** → **Backup (JSON)** to export
- Use **Import (JSON)** to restore (Replace or Merge)

## 🔮 Possible Improvements
- SwiftData / Core Data persistence
- Edit note text + category in a dedicated detail screen
- Tags (#) support
- Local notifications (reminders)
- Better error handling & UI feedback (toast/snackbar)
- Unit tests + MVVM refactor

## 🧑‍💻 Author
Neriman Akça  
Software Engineering student — exploring iOS development with SwiftUI.
