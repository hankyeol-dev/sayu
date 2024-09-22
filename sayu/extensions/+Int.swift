//
//  +Int.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import Foundation

extension Int {
   func convertTimeToString() -> String {
      let hours = self / 3600
      let minutes = (self % 3600) / 60
      let seconds = (self % 3600) % 60
      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
   }
   
   func converTimeToCardViewString() -> String {
      let hours = self / 3600
      let minutes = (self % 3600) / 60
      let seconds = (self % 3600) % 60
      
      return "\(hours != 0 ? "\(hours)시간 " : "")\(minutes != 0 ? "\(minutes)분 " : "")\(seconds != 0 ? "\(seconds)초": "")"
   }
}
