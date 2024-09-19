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
      case kjcRegular = "KimjungchulMyungjo-Regular"
      case kjcBold = "KimjungchulMyungjo-Bold"
      case satoshiLight = "SatoshiVariable-Bold_Light"
      case satoshiRegular = "SatoshiVariable-Bold_Regular"
      case satoshiMedium = "SatoshiVariable-Bold_Medium"
      case satoshiBold = "SatoshiVariable-Bold_Bold"
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
