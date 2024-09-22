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
      case dailySayu = "데일리 사유 작성"
      case dailyOver5000Steps = "데일리 5000보 걷기 성공"
      case dailyOver10000Steps = "데일리 10000보 걷기 성공"
   }
   
   enum PayCase: String {
      case buySayu = "사유 배지 구매"
   }
}
