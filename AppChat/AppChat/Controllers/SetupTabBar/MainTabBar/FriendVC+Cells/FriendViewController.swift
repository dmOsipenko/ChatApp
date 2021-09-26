

import UIKit
import FirebaseFirestore
import SDWebImage

class FriendViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationLable: UILabel!
    
    
    //сюда приходят users, с которыми можно начать активный чат
    var users: [MUser] = []
    // Сюда приходит текущий user
    private let currentUser: MUser
    private var activeChatRef: CollectionReference {
        return Firestore.firestore().collection(["users", currentUser.id, "friend"].joined(separator: "/"))
    }
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(FriendCell.self)
        ListenerServices.shared.usersObserve(users: users, reference: activeChatRef) { result in
            switch result {
            case .success(let users):
                self.users = users.filter({$0.id != self.currentUser.id})
                self.notification()
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    func notification() {
        if users.count == 0 {
            tableView.isHidden = true
            noNotificationLable.text = "У вас нет активных чатов"
        } else {
            noNotificationLable.isHidden = true
            tableView.isHidden = false
        }
    }
}

//MARK: UITableViewDelegate
extension FriendViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        let vc = ChatsViewController(currentUser: currentUser, friend: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = deleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            FireStoreServices.shared.deleteActiveChats(user: self.users[indexPath.row]) { result in
                switch result {
                case .success():
                    self.showAlert(with: "Успешно!", and: "Чат и все сообщения были удалены")
                case .failure(_):
                    print("Error")
                }
            }
            self.users.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "delete.left.fill")
        action.title = "Удалить"
        return action
    }
    
}

//MARK: UITableViewDataSource
extension FriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FriendCell.self), for: indexPath)
        guard let friendCell = cell as? FriendCell else {return cell}
        let user = users[indexPath.row]
        friendCell.setupWith(muser: user)
        friendCell.selectionStyle = .none
        return friendCell
    }
}
