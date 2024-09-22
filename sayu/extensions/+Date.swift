//
//  +Date.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation

extension Date {
   func formattedAppConfigure() -> String {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.timeZone = .autoupdatingCurrent
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: self)
   }
   
   func formattedForView() -> String {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.timeZone = .autoupdatingCurrent
      formatter.dateFormat = "M월 d일"
      return formatter.string(from: self)
   }
}

extension String {
   func formattedForView() -> Date? {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.timeZone = .autoupdatingCurrent
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.date(from: self)
   }
}
