import UIKit

final class StatisticService: StatisticServiceProtocol {
    private var correctAnswers: Double = 0.0
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: "correct")
            let total = storage.integer(forKey: "total")
            let date = storage.object(forKey: "date") as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: "correct")
            storage.set(newValue.total, forKey: "total")
            storage.set(newValue.date, forKey: "date")
        }
    }
    
    var correctAllAnswers: Double {
        get {
            return storage.double(forKey: "correctAllAnswers")
        }
        set {
            storage.set(newValue, forKey: "correctAllAnswers")
        }
    }
    
    var totalAccuracy: Double {
        get {
            return (correctAllAnswers / (10.0 * Double(gamesCount))) * 100
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount = gamesCount + 1
        let result = GameResult(correct: count, total: amount, date: Date())
        if !bestGame.isBetterThan(result){
            bestGame = result
        }
        correctAnswers = Double(count)
        correctAllAnswers = correctAllAnswers + correctAnswers
    }
}
