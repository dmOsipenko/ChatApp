
import UIKit

class MainTabBar: UITabBarController {
    
    private let currentUser: MUser
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    init (currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.delegate = self
        var controllers = [UIViewController]()
        
        let people = PeopleViewController(currentUser: currentUser)
        people.title = "Активные пользователи"
        people.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person.2.fill"), tag: 0)
        let peopleNav = UINavigationController(rootViewController: people)
        controllers.append(peopleNav)
        
        let friend = FriendViewController(currentUser: currentUser)
        friend.title = "Активные чаты"
        friend.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "message.fill"), tag: 1)
        let friendNav = UINavigationController(rootViewController: friend)
        controllers.append(friendNav)
        
        let notif = NotificationViewController(currentUser: currentUser)
        notif.title = "Заявки в друзья"
        notif.sendNotification()
        notif.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "bookmark"), tag: 2)
        let notifNav = UINavigationController(rootViewController: notif)
        controllers.append(notifNav)
        
        
        let profile = ProfileViewController(currentUser: currentUser)
        profile.title = "Ваш профиль"
        profile.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person.fill"), tag: 3)
        let profileNav = UINavigationController(rootViewController: profile)
        controllers.append(profileNav)
        
        self.viewControllers = controllers
    }
}

//MARK: UNUserNotificationCenterDelegate
extension MainTabBar: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }
}






