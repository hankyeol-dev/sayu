//
//  SayuTime.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation

struct SayuTime {
   var hours: Int
   var minutes: Int
   var seconds: Int
   
   var convertTimeToSeconds: Int {
      return (hours * 60 * 60) + (minutes * 60) + seconds
   }
}

extension Int {
   func convertTimeToString() -> String {
      let hours = self / 3600
      let minutes = (self % 3600) / 60
      let seconds = (self % 3600) % 60
      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
   }
}
