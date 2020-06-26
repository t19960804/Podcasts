//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by t19960804 on 2/29/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    var topAnchor: NSLayoutConstraint?
    
    let miniPlayerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .red
        return v
    }()
    let miniPlayerViewHeight: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoritesController = UIViewController()
        let searchController = SearchPodcastsController()
        let downloadsController = UIViewController()

        viewControllers = [generateNavController(rootController: searchController, tabBarTitle: "Search", tabBarImage: #imageLiteral(resourceName: "search")),
                           generateNavController(rootController: favoritesController, tabBarTitle: "Favorites", tabBarImage: #imageLiteral(resourceName: "favorites")),
                           
                           generateNavController(rootController: downloadsController, tabBarTitle: "Downloads", tabBarImage: #imageLiteral(resourceName: "downloads"))]
        //被點選的 tab 的文字和圖案顏色
        tabBar.tintColor = .purple
        setupConstraints()
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
    func setupConstraints(){
        //.addSubview > 將View往上疊 ; .insertSubview > 將View插入至某個View之下
        view.insertSubview(miniPlayerView, belowSubview: tabBar)
        miniPlayerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topAnchor = miniPlayerView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: miniPlayerViewHeight) //hide mini player when init
        topAnchor?.isActive = true
        miniPlayerView.heightAnchor.constraint(equalToConstant: miniPlayerViewHeight).isActive = true
        miniPlayerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    @objc func showMiniPodcastPlayerView(){
        topAnchor?.constant = -miniPlayerViewHeight
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    @objc func hideMiniPodcastPlayerView(){
        topAnchor?.constant = miniPlayerViewHeight
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}
