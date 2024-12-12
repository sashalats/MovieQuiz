import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-medium", size: 20)
        
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        //questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
        let statisticService = StatisticService()
        self.statisticService = statisticService
        showLoadingIndicator()
        questionFactory.loadData()
        activityIndicator.hidesWhenStopped = true
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        
        let alertPresenter = AlertPresenter(delegate: self)
        alertPresenter.showAlert(result: alert)
    }
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
            showLoadingIndicator()
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.hideLoadingIndicator()
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber}
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let alert = AlertModel(
            title: result.title,
            message: result.text,

            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        );
        
        let alertPresenter = AlertPresenter(delegate: self)
        alertPresenter.showAlert(result: alert)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            guard let bestResult = statisticService?.bestGame.date.dateTimeString else {
                return
            }
            let text = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
            Рекорд: \(statisticService?.bestGame.correct ?? 0)/10 ( \(bestResult))
            Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
            """
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1

            
            self.questionFactory?.requestNextQuestion()

        }
    }
    
    private func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = .zero
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
            self.changeStateButtons(isEnabled: true)

        }
    }
    

    private func handleAnswer(givenAnswer: Bool) {
        
        self.changeStateButtons(isEnabled: false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: false)
    }
    
    
    
}
