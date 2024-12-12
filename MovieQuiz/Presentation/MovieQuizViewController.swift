import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-medium", size: 20)
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        activityIndicator.hidesWhenStopped = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                self?.presenter.restartGame()
            }
        )
        
        let alertPresenter = AlertPresenter(delegate: self)
        alertPresenter.showAlert(result: alert)
    }
    
    func show(quiz step: QuizStepViewModel){
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber}
    
    func show(quiz result: QuizResultsViewModel) {
        
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter.restartGame()
            }
        )
        
        let alertPresenter = AlertPresenter(delegate: self)
        alertPresenter.showAlert(result: alert)
    }
    
    func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.handleAnswer(givenAnswer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.handleAnswer(givenAnswer: false)
    }
}
