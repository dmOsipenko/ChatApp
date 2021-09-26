
import UIKit

class ChatRequestViewController: UIViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var cityLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet var mainView: UIView!
    
    weak var delegate: NavigationDelegate?
    
    private let currentUser: MUser //i am
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLable.text = currentUser.userName
        self.avatarImage.sd_setImage(with: URL(string: currentUser.avatarStringURL), completed: nil)
        cityLable.text = currentUser.city
        emailLable.text = currentUser.email
        mainView.roundCorners([.topLeft, .topRight], radius: 20)
    }
    
    @IBAction func addFriendButton(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.goToActiveChats(user: self.currentUser)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.removeFriendRequest(user: self.currentUser)
        }
    }
}
