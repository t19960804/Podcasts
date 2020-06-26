//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by t19960804 on 2/29/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    var topAnchorForFullScreenPlayer: NSLayoutConstraint?
    var topAnchorForMiniPlayer: NSLayoutConstraint?
    
    let episodePlayerView = EpisodePlayerView()
    
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
        //miniPlayerView為全屏,縮小時會蓋住tabbar
        //.addSubview > 將View往上疊 ; .insertSubview > 將View插入至某個View之下
        view.insertSubview(episodePlayerView, belowSubview: tabBar)
        
        topAnchorForFullScreenPlayer = episodePlayerView.topAnchor.constraint(equalTo: view.topAnchor,constant: view.frame.height)//hide player when initialize
        topAnchorForFullScreenPlayer?.isActive = true
        
        let miniPlayerViewHeight: CGFloat = 80
        topAnchorForMiniPlayer = episodePlayerView.topAnchor.constraint(equalTo: tabBar.topAnchor,constant: -miniPlayerViewHeight)
        
        episodePlayerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        episodePlayerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        episodePlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    func maximizePodcastPlayerView(episode: Episode?){
        episodePlayerView.episode = episode
        
        topAnchorForMiniPlayer?.isActive = false
        topAnchorForFullScreenPlayer?.isActive = true

        topAnchorForFullScreenPlayer?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
        })
    }
    func minimizePodcastPlayerView(){
        topAnchorForFullScreenPlayer?.isActive = false
        topAnchorForMiniPlayer?.isActive = true
        
        tabBar.transform = .identity

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }


}
