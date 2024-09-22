//
//  +String.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import Foundation

extension String {
   func formattedForView() -> Date? {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.timeZone = .autoupdatingCurrent
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.date(from: self)
   }
}
