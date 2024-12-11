import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    internal var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func handleAnswer(givenAnswer: Bool) {
    
        viewController?.changeStateButtons(isEnabled: false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        viewController?.showLoadingIndicator()
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
        }
    }
    
    var correctAnswers: Int = 0
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            
            guard let bestResult = viewController?.statisticService?.bestGame.date.dateTimeString else {
                return
            }
            let text = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(viewController?.statisticService?.gamesCount ?? 0)
            Рекорд: \(viewController?.statisticService?.bestGame.correct ?? 0)/10 ( \(bestResult))
            Средняя точность: \(String(format: "%.2f", viewController?.statisticService?.totalAccuracy ?? 0))%
            """
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            viewController?.questionFactory?.requestNextQuestion()
        }
    }
    
}

