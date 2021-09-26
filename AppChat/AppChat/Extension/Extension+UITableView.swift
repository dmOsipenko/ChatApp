
import Foundation
import UIKit

// регестрирует ячейку и устанавливает delegate и dataSourse
extension UITableView {
    func registerCell(_ cellClass: AnyClass) {
        let nib = UINib(nibName: String(describing: cellClass.self), bundle: nil)
        self.register(nib, forCellReuseIdentifier: String(describing: cellClass.self))
    }
    
    func setupDelegateData(_ controller: UIViewController) {
        self.delegate = controller as? UITableViewDelegate
        self.dataSource = controller as? UITableViewDataSource
        self.tableFooterView = UIView()
    }
    
    func registerAllCells(_ cellClasses: [AnyClass]) {
        for cell in cellClasses {
            let nib = UINib(nibName: String(describing: cell.self), bundle: nil)
            self.register(nib, forCellReuseIdentifier: String(describing: cell.self))
        }
    }
}
