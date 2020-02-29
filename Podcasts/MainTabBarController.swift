//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by t19960804 on 2/29/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoritesController = UIViewController()
        let searchController = UIViewController()
        let downloadsController = UIViewController()

        viewControllers = [generateNavController(rootController: favoritesController, tabBarTitle: "Favorites", tabBarImage: #imageLiteral(resourceName: "favorites")),
                           generateNavController(rootController: searchController, tabBarTitle: "Search", tabBarImage: #imageLiteral(resourceName: "search")),
                           generateNavController(rootController: downloadsController, tabBarTitle: "Downloads", tabBarImage: #imageLiteral(resourceName: "downloads"))]
        //被點選的 tab 的文字和圖案顏色
        tabBar.tintColor = .purple
    }
    
    fileprivate func generateNavController(rootController: UIViewController, tabBarTitle: String, tabBarImage: UIImage) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootController)
        rootController.navigationController?.navigationBar.prefersLargeTitles = true
        rootController.navigationItem.title = tabBarTitle
        rootController.view.backgroundColor = .white
        rootController.tabBarItem.title = tabBarTitle
        rootController.tabBarItem.image = tabBarImage
        return navController
    }

}
