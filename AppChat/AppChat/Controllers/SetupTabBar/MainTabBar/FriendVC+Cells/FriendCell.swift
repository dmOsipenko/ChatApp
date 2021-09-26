

import UIKit

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var lable: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var messageLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.layer.borderWidth = 1
        avatarImage.layer.borderColor = UIColor.systemGray.cgColor
        avatarImage.layer.cornerRadius = 20
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupWith(muser: MUser) {
        lable.text = muser.userName
        messageLable.text = muser.message
        avatarImage.sd_setImage(with: URL(string: muser.avatarStringURL), completed: nil)
    }
}
