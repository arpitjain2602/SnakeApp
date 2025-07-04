import SwiftUI

struct ContentView: View {
    @StateObject private var game = SnakeGame()

    var body: some View {
        GameView(game: game)
            .padding()
            .preferredColorScheme(.dark)
            .onAppear {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 