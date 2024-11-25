import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    //метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        return correct > another.correct
    }
}
