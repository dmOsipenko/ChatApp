
import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var passwortTextField: UITextField!
    @IBOutlet weak var confPassTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 25
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let  tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        avatarImage.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        avatarImage.addGestureRecognizer(gesture)
    }
    
    @objc func didTapChangeProfilePic() {
        phothoActionSheet()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 1.5
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func signButtom(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwortTextField.text, let confPass = confPassTextField.text, let name = nameTextField.text, name != "" else {
            self.showAlert(with: "Ошибка", and: "Заполните обязательные поля")
            return
        }
        AuthService.shared.register(email: email, password: password, confirmPassword: confPass) { result in
            switch result {
            case .success(let user):
                guard let email = user.email, let name = self.nameTextField.text, let about = self.aboutTextField.text, let city = self.cityTextField.text else {return}
                FireStoreServices.shared.saveProfileWith(id: user.uid, email: email, username: name, avatarImage: self.avatarImage.image, description: about, city: city) { result in
                    switch result {
                    case .success(let muser):
                        self.showAlert(with: "Успешно!", and: "Данные сохранены!") {
                            let tb = MainTabBar(currentUser: muser)
                            tb.modalPresentationStyle = .fullScreen
                            self.present(tb, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        self.showAlert(with: "Error", and: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func phothoActionSheet() {
        let actionSheet = UIAlertController(title: "Воспользуйтесь галлереей, что бы выбрать фото",
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
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.avatarImage.contentMode = .scaleAspectFit
        self.avatarImage.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
