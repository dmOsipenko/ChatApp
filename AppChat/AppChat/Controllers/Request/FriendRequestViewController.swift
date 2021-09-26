

import UIKit

class FriendRequestViewController: UIViewController {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var cityLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var aboutLable: UILabel!
    @IBOutlet var mainView: UIView!
    
    
    private let friendUser: MUser
    
    init(currentUser: MUser) {
        self.friendUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLable.text = friendUser.userName
        self.avatarImage.sd_setImage(with: URL(string: friendUser.avatarStringURL), completed: nil)
        cityLable.text = friendUser.city
        emailLable.text = friendUser.email
        aboutLable.text = friendUser.description
        mainView.shadowView()
        mainView.roundCorners([.topLeft, .topRight], radius: 20)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(dismisButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus"), style: .plain, target: self, action: #selector(addFriend))
    }
    
    @objc func dismisButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addFriend() {
        FireStoreServices.shared.createFriendRequest(receiver: self.friendUser) { result in
            switch result {
            case .success():
                self.dismiss(animated: true) {
                    self.showAlert(with: "Успешно!", and: "Ваш запрос отправлен")
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
}




