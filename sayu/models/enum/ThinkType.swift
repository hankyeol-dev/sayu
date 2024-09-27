//
//  ThinkType.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation

@frozen
enum ThinkType: Int, CaseIterable {
   case stay
   case walk
   case run
   
   var byKoreanTypes: String {
      switch self {
      case .stay:
         "조용히 앉아서"
      case .walk:
         "걸으면서"
      case .run:
         "달리면서"
      }
   }
   
   static func byKoreanString(_ index: Int) -> String {
      return Self(rawValue: index)?.byKoreanTypes ?? ""
   }
}
