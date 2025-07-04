import Foundation
import SwiftUI

enum Direction {
    case up, down, left, right
}

struct Position: Equatable {
    var x: Int
    var y: Int
}

class SnakeGame: ObservableObject {
    let numRows: Int
    let numCols: Int
    @Published var snake: [Position]
    @Published var food: Position
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var direction: Direction = .right
    private var pendingDirection: Direction? = nil

    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore")

    private var timer: Timer?
    private var moveInterval: TimeInterval {
        // Speed up as score increases, min 0.07s
        max(0.15 - Double(score) * 0.01, 0.07)
    }

    // Feature toggles and obstacles for future features
    @Published var edgeWrappingEnabled: Bool = false
    @Published var obstacles: [Position] = []

    @Published var snakeColor: Color = .green
    @Published var snakeBodyColor: Color = .blue
    @Published var foodColor: Color = .red
    @Published var gridSize: (rows: Int, cols: Int) = (20, 20)
    @Published var numObstacles: Int = 5

    init(rows: Int = 20, cols: Int = 20) {
        self.numRows = rows
        self.numCols = cols
        self.snake = [Position(x: cols/2, y: rows/2)]
        self.food = Position(x: Int.random(in: 0..<cols), y: Int.random(in: 0..<rows))
        startGame()
    }

    func startGame() {
        snake = [Position(x: gridSize.cols/2, y: gridSize.rows/2)]
        direction = .right
        score = 0
        isGameOver = false
        numRows = gridSize.rows
        numCols = gridSize.cols
        spawnFood()
        spawnObstacles()
        timer?.invalidate()
        startTimer()
    }

    func stopGame() {
        timer?.invalidate()
        timer = nil
    }

    func setDirection(_ newDirection: Direction) {
        // Prevent reversing
        if (direction == .up && newDirection == .down) ||
            (direction == .down && newDirection == .up) ||
            (direction == .left && newDirection == .right) ||
            (direction == .right && newDirection == .left) {
            return
        }
        pendingDirection = newDirection
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: moveInterval, repeats: true) { [weak self] _ in
            self?.moveSnake()
        }
    }

    private func moveSnake() {
        guard !isGameOver else { return }
        if let pending = pendingDirection {
            direction = pending
            pendingDirection = nil
        }
        var newHead = snake[0]
        switch direction {
        case .up: newHead.y -= 1
        case .down: newHead.y += 1
        case .left: newHead.x -= 1
        case .right: newHead.x += 1
        }
        // Edge wrapping
        if edgeWrappingEnabled {
            newHead.x = (newHead.x + numCols) % numCols
            newHead.y = (newHead.y + numRows) % numRows
        }
        // Check collisions
        if (!edgeWrappingEnabled && (newHead.x < 0 || newHead.x >= numCols || newHead.y < 0 || newHead.y >= numRows)) || snake.contains(newHead) || obstacles.contains(newHead) {
            isGameOver = true
            stopGame()
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "HighScore")
            }
            onGameOver?()
            return
        }
        snake.insert(newHead, at: 0)
        if newHead == food {
            score += 1
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "HighScore")
            }
            spawnFood()
            // Speed up
            startTimer()
            onEatFood?()
        } else {
            snake.removeLast()
        }
    }

    private func spawnFood() {
        var newFood: Position
        repeat {
            newFood = Position(x: Int.random(in: 0..<numCols), y: Int.random(in: 0..<numRows))
        } while snake.contains(newFood)
        food = newFood
    }

    private func spawnObstacles() {
        obstacles = []
        var placed = 0
        while placed < numObstacles {
            let pos = Position(x: Int.random(in: 0..<numCols), y: Int.random(in: 0..<numRows))
            if !snake.contains(pos) && pos != food && !obstacles.contains(pos) {
                obstacles.append(pos)
                placed += 1
            }
        }
    }

    // Hooks for sound and haptic feedback
    var onEatFood: (() -> Void)?
    var onGameOver: (() -> Void)?
} 