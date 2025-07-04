# SnakeApp

A modular iOS Snake game built with Swift and SwiftUI.

## Requirements
- Xcode 13 or later (for iOS 15+)
- macOS (for development)
- iPhone (optional, for device testing)

## Setup Instructions

1. **Clone the repository**
   ```sh
   git clone <your-repo-url>
   cd SnakeApp
   ```

2. **Open in Xcode**
   - Open `SnakeApp.xcodeproj` or `SnakeApp.xcworkspace` in Xcode (create a new project if not present, then add these files).

3. **Build & Run**
   - Select an iPhone simulator (e.g., iPhone 13) or your connected iPhone.
   - Press the Run ▶️ button in Xcode.

4. **Gameplay**
   - Swipe to control the snake.
   - Eat the red food to grow and score points.
   - Avoid running into yourself or the wall.
   - Tap "Restart" after game over to play again.

## Project Structure
- `SnakeApp.swift`: App entry point
- `Models/SnakeGame.swift`: Game logic (snake, food, movement, scoring)
- `Views/GameView.swift`: Game board UI and controls
- `Views/ContentView.swift`: App root view

## Customization
The codebase is modular for easy extension (e.g., new game modes, themes, settings).

---

Enjoy playing and modifying SnakeApp! 