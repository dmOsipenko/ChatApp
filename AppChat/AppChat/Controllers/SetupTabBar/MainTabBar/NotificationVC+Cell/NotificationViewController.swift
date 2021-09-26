import UIKit
import FirebaseFirestore
import UserNotifications

class NotificationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationLable: UILabel!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var users: [MUser] = [] // i am
    var usersCount: [MUser] = []
        
    private let currentUser: MUser // friend
    
    private var friendRequestRef: CollectionReference {
        return Firestore.firestore().collection(["users", currentUser.id, "friendRequest"].joined(separator: "/"))
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
        tableView.registerCell(NotificationCell.self)
        ListenerServices.shared.usersObserve(users: users, reference: friendRequestRef) { result in
            switch result {
            case .success(let users):
                self.users = users.filter({$0.id != self.currentUser.id})
                self.sendNotification()
                self.notification()
                self.usersCount = self.users
                self.tabBarController?.tabBar.items?[2].badgeValue = "\(users.count)"
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    func notification() {
        if users.count == 0 {
            tableView.isHidden = true
            noNotificationLable.text = "У вас нет активных заявок"
        } else if users.count > 0 {
            noNotificationLable.isHidden = true
            tableView.isHidden = false
        }
    }
    
    func sendNotification() {
        if self.users.count > self.usersCount.count {
            let content = UNMutableNotificationContent()
            content.title = "Hовая зявка в друзья"
            content.body = "Посмотри кто хочет стать твоим другом"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                print(error ?? "Ошибка")
            }
        }else if self.users.count == 0 {
            return
        }
    }
}

//MARK: UITableViewDelegate
extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let users = users[indexPath.row]
        let vc = ChatRequestViewController(currentUser: users)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}
//MARK: UITableViewDataSource
extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NotificationCell.self), for: indexPath)
        guard let notifCell = cell as? NotificationCell else {return cell}
        let user = users[indexPath.row]
        notifCell.setupWith(user: user)
        return notifCell
    }
}
//MARK: Protocol_friendRequestNavigation
extension NotificationViewController: NavigationDelegate {
    func goToActiveChats(user: MUser) {
        FireStoreServices.shared.goToChats(user: user) { result in
            switch result {
            case .success():
                self.showAlert(with: "Успешно!", and: "Приятного общения с \(user.userName) .")
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    func removeFriendRequest(user: MUser) {
        FireStoreServices.shared.deleteFriendRequest(user: user) { result in
            switch result {
            case .success():
                    self.showAlert(with: "Успешно", and: "Заявка в дружбу от \(user.userName) была удалена.")
                ListenerServices.shared.usersObserve(users: self.users, reference: self.friendRequestRef) { result in
                    switch result {
                    case .success(let users):
                        self.users = users.filter({$0.id != self.currentUser.id})
                        self.sendNotification()
                        self.notification()
                        self.usersCount = self.users
                        self.tabBarController?.tabBar.items?[2].badgeValue = "\(users.count)"
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.showAlert(with: "Error", and: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
}



