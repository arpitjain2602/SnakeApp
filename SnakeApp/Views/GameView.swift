import SwiftUI
import AVFoundation
import UIKit

struct GameView: View {
    @ObservedObject var game: SnakeGame
    let cellSize: CGFloat = 16
    @State private var eatSound: AVAudioPlayer?
    @State private var gameOverSound: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Score: \(game.score)")
                    .font(.headline)
                Spacer()
                Text("High Score: \(game.highScore)")
                    .font(.subheadline)
            }
            .padding(.horizontal)
            ZStack {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: CGFloat(game.numCols) * cellSize, height: CGFloat(game.numRows) * cellSize)
                    .cornerRadius(8)
                // Obstacles
                ForEach(game.obstacles, id: \ .self) { pos in
                    Rectangle()
                        .foregroundColor(.brown)
                        .frame(width: cellSize, height: cellSize)
                        .position(x: CGFloat(pos.x) * cellSize + cellSize/2, y: CGFloat(pos.y) * cellSize + cellSize/2)
                }
                // Food
                Rectangle()
                    .foregroundColor(game.foodColor)
                    .frame(width: cellSize, height: cellSize)
                    .position(x: CGFloat(game.food.x) * cellSize + cellSize/2, y: CGFloat(game.food.y) * cellSize + cellSize/2)
                // Snake
                ForEach(0..<game.snake.count, id: \ .self) { i in
                    Rectangle()
                        .foregroundColor(i == 0 ? game.snakeColor : game.snakeBodyColor)
                        .frame(width: cellSize, height: cellSize)
                        .position(x: CGFloat(game.snake[i].x) * cellSize + cellSize/2, y: CGFloat(game.snake[i].y) * cellSize + cellSize/2)
                        .animation(.easeInOut(duration: 0.08), value: game.snake)
                }
            }
            .gesture(DragGesture(minimumDistance: 10)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    if abs(horizontal) > abs(vertical) {
                        if horizontal > 0 {
                            game.setDirection(.right)
                        } else {
                            game.setDirection(.left)
                        }
                    } else {
                        if vertical > 0 {
                            game.setDirection(.down)
                        } else {
                            game.setDirection(.up)
                        }
                    }
                }
            )
            .overlay(
                Group {
                    if game.isGameOver {
                        Color.black.opacity(0.5)
                        VStack {
                            Text("Game Over")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Button("Restart") {
                                game.startGame()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                    }
                }
            )
            HStack(spacing: 16) {
                Button(game.timer == nil ? "Resume" : "Pause") {
                    if game.timer == nil {
                        game.startGame()
                    } else {
                        game.stopGame()
                    }
                }
                .padding(.horizontal)
                Toggle("Edge Wrap", isOn: $game.edgeWrappingEnabled)
                    .padding(.horizontal)
            }
            .padding(.top, 8)
            VStack(spacing: 8) {
                HStack {
                    Text("Snake Head Color")
                    ColorPicker("", selection: $game.snakeColor).labelsHidden()
                    Text("Body")
                    ColorPicker("", selection: $game.snakeBodyColor).labelsHidden()
                }
                HStack {
                    Text("Food Color")
                    ColorPicker("", selection: $game.foodColor).labelsHidden()
                }
                HStack {
                    Text("Grid Size")
                    Picker("Rows", selection: $game.gridSize.rows) {
                        ForEach([10, 15, 20, 25, 30], id: \ .self) { size in
                            Text("\(size)")
                        }
                    }.pickerStyle(.segmented)
                    Picker("Cols", selection: $game.gridSize.cols) {
                        ForEach([10, 15, 20, 25, 30], id: \ .self) { size in
                            Text("\(size)")
                        }
                    }.pickerStyle(.segmented)
                }
                HStack {
                    Text("Obstacles")
                    Slider(value: Binding(get: { Double(game.numObstacles) }, set: { game.numObstacles = Int($0) }), in: 0...15, step: 1)
                    Text("\(game.numObstacles)")
                }
            }
            .padding(.vertical, 8)
        }
        .onAppear {
            setupSounds()
            game.onEatFood = {
                playEatSound()
                playHaptic(style: .light)
            }
            game.onGameOver = {
                playGameOverSound()
                playHaptic(style: .heavy)
            }
        }
    }

    private func setupSounds() {
        if let eatURL = Bundle.main.url(forResource: "eat", withExtension: "wav") {
            eatSound = try? AVAudioPlayer(contentsOf: eatURL)
        }
        if let gameOverURL = Bundle.main.url(forResource: "gameover", withExtension: "wav") {
            gameOverSound = try? AVAudioPlayer(contentsOf: gameOverURL)
        }
    }
    private func playEatSound() {
        eatSound?.play()
    }
    private func playGameOverSound() {
        gameOverSound?.play()
    }
    private func playHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
} 