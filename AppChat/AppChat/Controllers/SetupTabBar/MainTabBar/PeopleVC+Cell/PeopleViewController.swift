

import UIKit
import FirebaseFirestore


class PeopleViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!    
    
    
    var users = [MUser]()
    var filteredUsers: [MUser] = []
    var isSearch = false
    var userBlock: ((MUser) ->())?
    
    private let currentUser: MUser
    private var usersRef: CollectionReference {
        return Firestore.firestore().collection("users")
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
        setupSearchBar()
        tableView.setupDelegateData(self)
        tableView.registerCell(PeopleCell.self)
        ListenerServices.shared.usersObserve(users: users, reference: usersRef) { result in
            switch result {
            case .success(let users):
                self.users = users.filter({$0.id != self.currentUser.id})
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Поиск по людям"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }    
}

//MARK: UITableViewDelegate
extension PeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let vc = FriendRequestViewController(currentUser: user)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    func doneAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
            FireStoreServices.shared.createFriendRequest(receiver: self.users[indexPath.row]) { result in
                switch result {
                case .success():
                        self.showAlert(with: "Успешно!", and: "Запрос \(self.users[indexPath.row].userName) отправлен ")
                case .failure(let error):
                    self.showAlert(with: "Error", and: error.localizedDescription)
                }
            }
            completion(true)
        }
        action.backgroundColor = .systemGreen
        action.image = UIImage(systemName: "person.badge.plus")
        action.title = "Добавить"
        return action
    }
}


//MARK: UITableViewDataSourse
extension PeopleViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearch ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PeopleCell.self), for: indexPath)
        guard let peopleCell = cell as? PeopleCell else {return cell}
        let user = isSearch ? filteredUsers[indexPath.row] : users[indexPath.row]
        peopleCell.selectionStyle = .none
        peopleCell.setupWith(muser: user)
        return peopleCell
    }
}

//MARK: UISearchControllerDelegate
extension PeopleViewController: UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            isSearch = false
            filteredUsers.removeAll()
            tableView.reloadData()
            return
        }
        isSearch = true
        filteredUsers = users.filter({$0.userName.lowercased().contains(searchText.lowercased())})
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
        filteredUsers.removeAll()
        tableView.reloadData()
    }
}




