//
//  AppDelegate.swift
//  Podcasts
//
//  Created by t19960804 on 2/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var backgroundCompletionHandler: (() -> Void)?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            //In SceneDelegate
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = MainTabBarController()
            window?.makeKeyAndVisible()
        }
        //在程式一啟動即詢問使用者是否接受圖文(alert)、聲音(sound)、數字(badge)三種類型的通知
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge, .carPlay], completionHandler: { (granted, error) in
            if granted {
                print("Info-允許接受通知")
                UNUserNotificationCenter.current().delegate = self
            } else {
                print("Info-不允許接受通知")
            }
        })
        return true
    }
    //點擊通知觸發的事件
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        completionHandler()
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let episodeData = content.userInfo[UNUserNotificationCenter.episodeDataKey]! as! Data
        let episode = try! JSONDecoder().decode(EpisodeCellViewModel.self, from: episodeData)
        let downloadEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        tabbarController.maximizePodcastPlayerView(episodeViewModel: episode, episodesList: downloadEpisodes)
    }
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        //Call this completion handler lets the system know that your app’s user interface is updated and a new snapshot can be taken
            backgroundCompletionHandler = completionHandler
    }
}

