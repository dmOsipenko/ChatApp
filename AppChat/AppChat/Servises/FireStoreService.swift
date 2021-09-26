
import Foundation
import Firebase
import FirebaseFirestore

class FireStoreServices {
    static let shared = FireStoreServices()
    
    let db = Firestore.firestore()
    
    private var userRef: CollectionReference {
        return db.collection("users")
    }
    
    private var friendRequestRef: CollectionReference {
        return db.collection(["users", currentUser.id, "friendRequest"].joined(separator: "/"))
    }
    
 
    private var activeChatRef: CollectionReference {
        return db.collection(["users", currentUser.id, "friend"].joined(separator: "/"))
    }
    
    var currentUser: MUser! // это авторизованный пользователь
    
    //MARK: Пытается достать user из firebaseFirestore.
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = userRef.document(user.uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                guard let muser = MUser(document: document) else {
                    completion(.failure(UserError.cannotAnwrapToMUser))
                    return
                }
                self.currentUser = muser
                completion(.success(muser))
            }else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    //MARK: Сохраняет user в firebaseFirestore и Storage.
    func saveProfileWith(id: String, email: String, username: String, avatarImage: UIImage?, description: String?, city: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        guard Validators.isFilled(username: username, description: description, city: city) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        guard avatarImage != nil else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        guard let image = avatarImage else {return}
        
        let muser = MUser(username: username, email: email, description: description, avatarStringURL: "not exist", id: id, city: city, message: "")
        StorageServices.shared.upload(photo: image) { result in
            switch result {
            case .success(let url):
                muser.avatarStringURL = url.absoluteString
                self.userRef.document(muser.id).setData(muser.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                    }else {
                        completion(.success(muser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        } //StorageServices
    }//saveProfileWith
    
    
    //MARK: Создает коллекцию, в которой хранятся документы тех userов, которые подали заявку в друзья.
    func createFriendRequest(receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "friendRequest"].joined(separator: "/"))
        
        reference.document(currentUser.id).setData(currentUser.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(Void()))
        }
    }
    
    //MARK: Удаляет коллекцию, в которой хранятся документы тех userов, которые подали заявку в друзья.
    func deleteFriendRequest(user: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        friendRequestRef.document(user.id).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(Void()))
        }
    }
    
    //MARK: Создает коллекцию, в которой хранятся документы друзей.
    func goToChats(user: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteFriendRequest(user: user) { result in
            switch result {
            case .success(_):
                let friendRef = self.db.collection(["users", self.currentUser.id, "friend"].joined(separator: "/"))
                friendRef.document(user.id).setData(user.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
                let reference = self.db.collection(["users", user.id, "friend"].joined(separator: "/"))
                reference.document(self.currentUser.id).setData(self.currentUser.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //MARK: Удаляет коллекцию друзей и сообщений из firebaseFirestre.
    func deleteActiveChats(user: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRefMessage = userRef.document(user.id).collection("friend").document(currentUser.id).collection("Messages")
        let myMessageRef = userRef.document(currentUser.id).collection("friend").document(user.id).collection("Messages")
        friendRefMessage.getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                document.reference.delete()
            }
            self.userRef.document(user.id).collection("friend").document(self.currentUser.id).delete()
            completion(.success(Void()))
        }
        myMessageRef.getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                document.reference.delete()
            }
            self.userRef.document(self.currentUser.id).collection("friend").document(user.id).delete()
            completion(.success(Void()))
        }
        
    }
    //MARK: Создает коллекцию сообщений.
    func sendMessage(user: MUser, message: MMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRefMessage = userRef.document(user.id).collection("friend").document(currentUser.id).collection("Messages")
        let myMessageRef = userRef.document(currentUser.id).collection("friend").document(user.id).collection("Messages")
        
        let chatForFriend = MUser(username: currentUser.userName, email: currentUser.email, description: currentUser.description, avatarStringURL: currentUser.avatarStringURL, id: currentUser.id, city: currentUser.city, message: message.content)
        userRef.document(user.id).collection("friend").document(currentUser.id).setData(chatForFriend.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            friendRefMessage.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                myMessageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
}

