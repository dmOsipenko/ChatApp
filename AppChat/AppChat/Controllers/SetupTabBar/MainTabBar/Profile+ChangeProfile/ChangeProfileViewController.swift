

import UIKit

class ChangeProfileViewController: UIViewController {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var mainView: UIView!
    
    
    
    private var currentUser: MUser
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var userBlock: ((MUser) ->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = currentUser.userName
        cityTextField.text = currentUser.city
        emailTextField.text = currentUser.email
        aboutTextField.text = currentUser.description
        avatarImage.sd_setImage(with: URL(string: currentUser.avatarStringURL), completed: nil)
        mainView.roundCorners([.topLeft, .topRight], radius: 20)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(changeProfile))
        avatarImage.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        avatarImage.addGestureRecognizer(gesture)
        let  tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func didTapChangeProfilePic() {
        phothoActionSheet()
    }
    
    @objc func changeProfile() {
        self.dismiss(animated: true) {
            guard let name = self.nameTextField.text else {return}
            FireStoreServices.shared.saveProfileWith(id: self.currentUser.id, email: self.currentUser.email, username: name, avatarImage: self.avatarImage.image, description: self.aboutTextField.text, city: self.cityTextField.text) { result in
                switch result {
                case .success(let muser):
                    self.dismiss(animated: true) {
                        self.showAlert(with: "Успешно!", and: "Ваши данные изменены")
                        self.userBlock?(muser)
                        let _ = ProfileViewController(currentUser: muser)
                    }
                case .failure(let error):
                    self.showAlert(with: "Ошибка!", and: error.localizedDescription)
                }
            }
        }
    }
}

extension ChangeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func phothoActionSheet() {
        let actionSheet = UIAlertController(title: "Воспользуйтесь галлереей, что изменить фото профиля",
                                            message: "",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        //        actionSheet.addAction(UIAlertAction(title: "Камера",
        //                                            style: .default,
        //                                            handler: { [weak self] _ in
        //                                                self?.presentCamera()
        //
        //                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Галлерея",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
                                                
                                            }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    //    func presentCamera() {
    //        let vc = UIImagePickerController()
    //        vc.sourceType = .camera
    //        vc.delegate = self
    //        vc.allowsEditing = true
    //        present(vc, animated: true, completion: nil)
    //    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        self.avatarImage.contentMode = .scaleAspectFit
        self.avatarImage.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



