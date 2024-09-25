//
//  RoundedTextField.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import SwiftUI

struct RoundedTextField: View {
   private var fieldText: Binding<String>
   private var placeholder: String
   private var font: Font.CustomFont
   private var fontSize: CGFloat
   private var tint: Color = .baseBlack
   private var background: Color
   private var foregroud: Color
   private var borderWidth: CGFloat
   private var height: CGFloat
   
   init(
      fieldText: Binding<String>,
      placeholder: String = "",
      font: Font.CustomFont = .gmlight,
      fontSize: CGFloat = 12.0,
      tint: Color = .baseBlack,
      background: Color = .white,
      foregroud: Color = .grayXl,
      borderWidth: CGFloat = 1.0,
      height: CGFloat = 40.0
   ) {
      self.fieldText = fieldText
      self.placeholder = placeholder
      self.font = font
      self.fontSize = fontSize
      self.tint = tint
      self.background = background
      self.foregroud = foregroud
      self.borderWidth = borderWidth
      self.height = height
   }
   
   var body: some View {
      RoundedRectangle(cornerRadius: 12.0)
         .stroke(lineWidth: borderWidth)
         .background(background)
         .foregroundStyle(foregroud)
         .frame(height: height)
         .clipShape(.rect(cornerRadius: 12.0))
         .overlay {
            TextField(placeholder, text: fieldText)
               .padding(.leading, 12.0)
               .font(.byCustomFont(font, size: fontSize))
               .tint(tint)
         }
   }
}

#Preview {
   @State var fieldText: String = ""
   
   return RoundedTextField(fieldText: $fieldText,
                           placeholder: "입력")
}
