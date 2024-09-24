//
//  SayuPointType.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation

@frozen
enum SayuPointType: Int {
   case earn
   case pay
   
   enum EarningCase: String {
      case firstJoin = "앱 처음 접속"
      case dailyVisit = "매일매일 접속"
      case dailySayu = "오늘의 사유 작성"
      case dailyOver5Sayu = "하루 사유 5번 이상 작성"
      case dailyOver1000Steps = "매일 1000보 걷기 성공"
      case dailyOver5000Steps = "매일 5000보 걷기 성공"
      case dailyOver10000Steps = "매일 10000보 걷기 성공"
      
      var byEarningPoint: Int {
         switch self {
         case .firstJoin:
            10
         case .dailyVisit:
            1
         case .dailySayu:
            1
         case .dailyOver5Sayu:
            3
         case .dailyOver1000Steps:
            1
         case .dailyOver5000Steps:
            2
         case .dailyOver10000Steps:
            3
         }
      }
   }
   
   enum PayCase: String {
      case getSayuItem = "사유 아이템 교환"
      case getPastSayuWrite = "지난 사유 작성권 교환"
      
      var byPayPoint: Int {
         switch self {
         case .getSayuItem:
            2
         case .getPastSayuWrite:
            2
         }
      }
   }
}
