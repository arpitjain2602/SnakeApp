import SwiftUI

struct GameView: View {
    @ObservedObject var game: SnakeGame
    let cellSize: CGFloat = 16

    var body: some View {
        VStack(spacing: 16) {
            Text("Score: \(game.score)")
                .font(.headline)
            ZStack {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: CGFloat(game.numCols) * cellSize, height: CGFloat(game.numRows) * cellSize)
                    .cornerRadius(8)
                // Food
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: cellSize, height: cellSize)
                    .position(x: CGFloat(game.food.x) * cellSize + cellSize/2, y: CGFloat(game.food.y) * cellSize + cellSize/2)
                // Snake
                ForEach(0..<game.snake.count, id: \ .self) { i in
                    Rectangle()
                        .foregroundColor(i == 0 ? .green : .blue)
                        .frame(width: cellSize, height: cellSize)
                        .position(x: CGFloat(game.snake[i].x) * cellSize + cellSize/2, y: CGFloat(game.snake[i].y) * cellSize + cellSize/2)
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
        }
    }
} 