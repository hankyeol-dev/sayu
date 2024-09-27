//
//  AsRoundedRect.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import SwiftUI

struct AsRoundedRect: ViewModifier {
   private var radius: CGFloat
   private var background: Color
   private var foreground: Color
   private var height: CGFloat
   private var title: String
   private var fontSize: CGFloat
   private var font: Font.CustomFont
   
   init(
      title: String,
      radius: CGFloat,
      background: Color,
      foreground: Color,
      height: CGFloat,
      fontSize: CGFloat,
      font: Font.CustomFont
   ) {
      self.title = title
      self.radius = radius
      self.background = background
      self.foreground = foreground
      self.height = height
      self.fontSize = fontSize
      self.font = font
   }
   
   func body(content: Content) -> some View {
      RoundedRectangle(cornerRadius: radius)
         .fill(background)
         .frame(maxWidth: .infinity)
         .frame(height: height)
         .overlay {
            Text(title)
               .byCustomFont(font, size: fontSize)
               .foregroundStyle(foreground)
         }
   }
}
