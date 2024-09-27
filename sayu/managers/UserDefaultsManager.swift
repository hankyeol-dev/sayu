//
//  UserDefaultsManager.swift
//  sayu
//
//  Created by 강한결 on 9/26/24.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T> {
   private let standard = UserDefaults.standard
   private let key: AppEnvironment.UserDefaultsKeys
   let defaultValue: T
   
   init(key: AppEnvironment.UserDefaultsKeys, defaultValue: T) {
      self.key = key
      self.defaultValue = defaultValue
   }
   
   var wrappedValue: T {
      get {
         standard.value(forKey: key.rawValue) as? T ?? defaultValue
      }
      
      set {
         standard.setValue(newValue, forKey: key.rawValue)
      }
   }
}

struct UserDefaultsManager {
   @UserDefaultsWrapper(key: .isShowAppDeleteNotikey, defaultValue: false)
   static var isShowSayuPointDeleteNoti: Bool
   
   @UserDefaultsWrapper(key: .isShowAppDeleteChartNotiKey, defaultValue: false)
   static var isShowAppDeleteChartNoti: Bool
   
   @UserDefaultsWrapper(key: .isShowOnboardingViewKey, defaultValue: true)
   static var isShowOnboardingView: Bool
}
