//
//  AppMainNavbar.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import SwiftUI

import MijickNavigationView

struct AppMainNavbar<Left, Right>: NavigatableView where Left: View, Right: View {
   
   private var leftButton: (() -> Left)?
   private var rightButton: (() -> Right)?
   
   init(
      leftButton: (() -> Left)? = nil,
      rightButton: (() -> Right)? = nil
   ) {
      self.leftButton = leftButton
      self.rightButton = rightButton
   }
   
   var body: some View {
      HStack(alignment: .center) {
         if let leftButton {
            Spacer.width(16.0)
            leftButton()
         }
         Spacer()
         if let rightButton {
            rightButton()
            Spacer.width(16.0)
         }
      }
      .padding(.vertical, 12.0)
      .frame(maxHeight: 48.0)
      .frame(maxWidth: .infinity)
      .background(.basebeige)
   }
}
