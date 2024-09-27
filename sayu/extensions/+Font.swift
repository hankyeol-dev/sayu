//
//  +Font.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

extension Font {
   enum CustomFont: String {
      case gmlight = "GmarketSansTTFLight"
      case gmMedium = "GmarketSansTTFMedium"
      case gmBold = "GmarketSansTTFBold"
      case dos = "DOSIyagiMedium"
   }
   
   static func byCustomFont(_ font: CustomFont, size: CGFloat) -> Self {
      Self.custom(font.rawValue, size: size)
   }
}

extension Text {
   func byCustomFont(_ font: Font.CustomFont, size: CGFloat) -> Self {
      self.font(Font.byCustomFont(font, size: size))
   }
}
