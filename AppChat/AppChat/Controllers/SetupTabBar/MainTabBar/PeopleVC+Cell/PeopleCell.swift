

import UIKit
import SDWebImage

class PeopleCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.layer.cornerRadius = 20
        avatarImage.layer.borderWidth = 1
        avatarImage.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupWith(muser: MUser) {
        nameLable.text = muser.userName
        avatarImage.sd_setImage(with: URL(string: muser.avatarStringURL), completed: nil)
    }
}
