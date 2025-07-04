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

    private var timer: Timer?
    private let moveInterval: TimeInterval = 0.15

    init(rows: Int = 20, cols: Int = 20) {
        self.numRows = rows
        self.numCols = cols
        self.snake = [Position(x: cols/2, y: rows/2)]
        self.food = Position(x: Int.random(in: 0..<cols), y: Int.random(in: 0..<rows))
        startGame()
    }

    func startGame() {
        snake = [Position(x: numCols/2, y: numRows/2)]
        direction = .right
        score = 0
        isGameOver = false
        spawnFood()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: moveInterval, repeats: true) { [weak self] _ in
            self?.moveSnake()
        }
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
        // Check collisions
        if newHead.x < 0 || newHead.x >= numCols || newHead.y < 0 || newHead.y >= numRows || snake.contains(newHead) {
            isGameOver = true
            stopGame()
            return
        }
        snake.insert(newHead, at: 0)
        if newHead == food {
            score += 1
            spawnFood()
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
} 