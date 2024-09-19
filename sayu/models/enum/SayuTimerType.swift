//
//  SayuTimerType.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation

@frozen
enum SayuTimerType: Int, CaseIterable, Hashable {
   case timer
   case stopWatch
   
   var byKoreanTitle: String {
      switch self {
      case .timer:
         "타이머 방식"
      case .stopWatch:
         "스톱워치 방식"
      }
   }
}
