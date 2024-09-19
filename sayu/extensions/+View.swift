//
//  +View.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import SwiftUI

extension View {
   func asRoundedRect(
      title: String,
      radius: CGFloat = 12.0,
      background: Color = .baseBlack,
      foreground: Color = .white,
      height: CGFloat = 44.0,
      fontSize: CGFloat = 16.0,
      font: Font.CustomFont = .satoshiRegular
   ) -> some View {
      return self.modifier(AsRoundedRect(
         title: title,
         radius: radius,
         background: background,
         foreground: foreground,
         height: height,
         fontSize: fontSize,
         font: font)
      )
   }
}