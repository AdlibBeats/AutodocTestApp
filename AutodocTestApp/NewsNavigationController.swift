//
//  NewsNavigationController.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import UIKit

final class AutodocNavigationController: UINavigationController, UINavigationControllerDelegate {
    final class BackBarButtonItem: UIBarButtonItem {
        @available(iOS 14.0, *)
        override var menu: UIMenu? {
            set {

            }
            get {
                return super.menu
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        navigationBar.prefersLargeTitles = false
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()

        navigationBar.backgroundColor = .black
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : navigationBar.tintColor ?? .white]
        navigationBar.largeTitleTextAttributes = navigationBar.titleTextAttributes

        view?.backgroundColor = navigationBar.backgroundColor
        navigationBar.barTintColor = navigationBar.backgroundColor
    }

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
