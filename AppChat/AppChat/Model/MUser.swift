

import UIKit
import FirebaseFirestore

class MUser {
    var userName: String
    var email: String
    var description: String?
    var city: String?
    var avatarStringURL: String
    var id: String
    var message: String?
    
    
    init(username: String, email: String, description: String?, avatarStringURL: String, id: String, city: String?, message: String?) {
        self.userName = username
        self.email = email
        self.description = description
        self.avatarStringURL = avatarStringURL
        self.id = id
        self.city = city
        self.message = message
    }
    
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {return nil}
        guard let userName = data["userName"] as? String,
              let email = data["email"] as? String,
              let description = data["description"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String,
              let city = data["city"] as? String?,
              let message = data["message"] as? String?,
              let id = data["uid"] as? String else {return nil}
        
        self.userName = userName
        self.email = email
        self.description = description
        self.avatarStringURL = avatarStringURL
        self.city = city
        self.id = id
        self.message = message
    }
    
    var representation: [String:Any] {
        var rep = ["userName":userName]
        rep["email"] = email
        rep["description"] = description
        rep["avatarStringURL"] = avatarStringURL
        rep["city"] = city
        rep["uid"] = id
        rep["message"] = message
        return rep
    }
}
