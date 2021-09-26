

import UIKit
import SDWebImage
import FirebaseAuth

class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var cityLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var aboutLable: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    private var currentUser: MUser
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.roundCorners([.topLeft, .topRight], radius: 20)
        avatarImage.sd_setImage(with: URL(string: currentUser.avatarStringURL), completed: nil)
        nameLable.text = currentUser.userName
        cityLable.text = currentUser.city
        emailLable.text = currentUser.email
        aboutLable.text = currentUser.description
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(didTapSignOut))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(changeProfile))
    }
    
    
    @objc func changeProfile() {
        let vc = ChangeProfileViewController(currentUser: currentUser)
        let nav = UINavigationController(rootViewController: vc)
        vc.userBlock = { [weak self] user in
            self?.nameLable.text = user.userName
            self?.cityLable.text = user.city
            self?.emailLable.text = user.email
            self?.aboutLable.text = user.description
            self?.avatarImage.sd_setImage(with: URL(string: user.avatarStringURL), completed: nil)
            self?.currentUser = user
        }
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(title: "Вы действительно хотите выйти из приложения?", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: {  _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
}
