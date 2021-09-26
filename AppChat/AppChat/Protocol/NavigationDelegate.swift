
import Foundation

protocol NavigationDelegate: AnyObject {
    func removeFriendRequest(user: MUser)
    func goToActiveChats(user: MUser)
}
