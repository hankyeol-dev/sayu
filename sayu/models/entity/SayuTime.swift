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

