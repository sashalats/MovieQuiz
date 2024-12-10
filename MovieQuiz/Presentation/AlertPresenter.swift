import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    weak private var delegate: UIViewController?
    
    init (delegate: UIViewController) {
        self.delegate = delegate
    }
    func showAlert(result: AlertModel?) {
        let alert = UIAlertController(
            title: result?.title,
            message: result?.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result?.buttonText, style: .default) { _ in
            result?.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
