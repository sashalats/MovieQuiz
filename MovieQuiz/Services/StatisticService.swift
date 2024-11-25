import UIKit

// Расширяем при объявлении

class StatisticService: StatisticServiceProtocol {
    private var correctAnswers: Double = 0.0
    private let storage: UserDefaults = .standard
    
    // Ключи для всех сущностей, которые придётся сохранить
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    
    var gamesCount: Int {
        get {
            // Добавьте чтение значения из UserDefaults
            
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            // Добавьте запись значения newValue из UserDefaults
            
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            // Добавьте чтение значений полей GameResult(correct, total и date) из UserDefaults,
            // затем создайте GameResult от полученных значений
            
            let correct = storage.integer(forKey: "correct")
            let total = storage.integer(forKey: "total")
            let date = storage.object(forKey: "date") as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            // Добавьте запись значений каждого поля из newValue из UserDefaults
            
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
            // Высчитываем среднюю точность
            
            return (self.correctAllAnswers / (10.0 * Double(gamesCount))) * 100
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // Сохраняем количество игр
        
        gamesCount = gamesCount + 1
        
        // Формируем переменную-константу с данным структуры GameResult
        
        let result = GameResult(correct: count, total: amount, date: Date())
        
        // Сохраняем результат
        
        if (!bestGame.isBetterThan(result)){
            bestGame = result
        }
        
        // Сохраняем количество правильным ответов за раунд
        
        self.correctAnswers = Double(count)
        
        // Обновляем количество правильным ответов за все игры
        
        self.correctAllAnswers = self.correctAllAnswers + self.correctAnswers
    }
}
