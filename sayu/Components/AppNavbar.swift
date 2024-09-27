//
//  AppNavbar.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

struct AppNavbar: View {
   private var title: String
   private var isLeftButton: Bool
   private var leftButtonAction: (() -> Void)?
   /// image asset name
   private var leftButtonIcon: ImageResource?
   
   private var isRightButton: Bool
   private var rightButtonAction: (() -> Void)?
   private var rightButtonIcon: ImageResource?
   
   
   init(
      title: String,
      isLeftButton: Bool,
      leftButtonAction: (() -> Void)? = nil,
      leftButtonIcon: ImageResource? = nil,
      isRightButton: Bool,
      rightButtonAction: (() -> Void)? = nil,
      rightButtonIcon: ImageResource? = nil
   ) {
      self.title = title
      self.isLeftButton = isLeftButton
      self.leftButtonAction = leftButtonAction
      self.leftButtonIcon = leftButtonIcon
      self.isRightButton = isRightButton
      self.rightButtonAction = rightButtonAction
      self.rightButtonIcon = rightButtonIcon
   }
   
   var body: some View {
      HStack(alignment: .center) {
         if isLeftButton {
            Button { leftButtonAction?() } label: {
               if let leftButtonIcon {
                  Image(leftButtonIcon)
                     .resizable()
                     .frame(width: 16.0, height: 8.0)
               } else {
                  Image(.arrowBack)
                     .resizable()
                     .frame(width: 16.0, height: 8.0)
               }
            }
         }
         
         Spacer()
         
         Text(title)
            .byCustomFont(.gmMedium, size: 16.0)
            .foregroundStyle(.baseBlack)
            .offset(x: isLeftButton && !isRightButton
                    ? -8.0
                    : !isLeftButton && isRightButton 
                    ? 8.0
                    : 0)
         
         Spacer()
         
         if isRightButton {
            Button { rightButtonAction?() } label: {
               if let rightButtonIcon {
                  Image(rightButtonIcon)
                     .resizable()
                     .frame(width: 16.0, height: 16.0)
               } else {
                  Image(.xmark)
                     .resizable()
                     .frame(width: 16.0, height: 16.0)
               }
            }
         }
      }
      .padding(.horizontal, 16.0)
      .padding(.vertical, 12.0)
      .frame(maxHeight: 48.0)
      .background(.basebeige)
      .shadow(color: .grayMd, radius: 0.5, y: 0.5)
   }
}
