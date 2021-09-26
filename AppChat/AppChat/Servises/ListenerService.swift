


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ListenerServices {
    
    static let shared = ListenerServices()
    
    private let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    //MARK: Listener, который сделит за всеми user в реальном времени.
    func usersObserve(users: [MUser], reference: CollectionReference, completion: @escaping (Result<[MUser], Error>) -> Void) {
        reference.addSnapshotListener { (querySnapshot, error) in
            var users = users
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let muser = MUser(document: document) else {return}
                let user = muser
                user.id = document.documentID
                users.append(user)
            }
            completion(.success(users))
        }
    }
    
    //MARK: Listener, который сделит за всеми сообщениями в реальном времени.
    func messageObserve(user: MUser, completion: @escaping (Result<MMessage, Error>) -> Void) -> ListenerRegistration? {
        let ref = usersRef.document(currentUserId).collection("friend").document(user.id).collection("Messages")
        let messagesListener = ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { diff in
                guard let message = MMessage(document: diff.document) else {return}
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
            
        }
        return messagesListener
    }
}
