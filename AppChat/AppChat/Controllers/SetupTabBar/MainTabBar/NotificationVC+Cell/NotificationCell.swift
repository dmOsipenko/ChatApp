

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.layer.cornerRadius = 20
        avatarImage.layer.borderWidth = 1
        avatarImage.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    func setupWith(user: MUser){
        avatarImage.sd_setImage(with: URL(string: user.avatarStringURL), completed: nil)
        nameLable.text = user.userName
    }
}
    

