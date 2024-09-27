//
//  AppDelegate.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
   var notificationDelegate: NotificationDelegate = .init()
   
   func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
   ) -> Bool {
      UNUserNotificationCenter.current().delegate = notificationDelegate
      return true
   }
}
