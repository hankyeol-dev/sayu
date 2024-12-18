//
//  BottomAlert.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

import MijickPopupView

struct BottomPopupButtonItem: Identifiable {
   let id: UUID = .init()
   var title: String
   var background: Color
   var foreground: Color
   var action: () -> Void
}

struct BottomAlert: BottomPopup {
   private var title: String
   private var content: String
   private var buttons: [BottomPopupButtonItem]?
   
   init(
      title: String,
      content: String,
      buttons: [BottomPopupButtonItem]? = nil
   ) {
      self.title = title
      self.content = content
      self.buttons = buttons
   }
   
   func createContent() -> some View {
      VStack(alignment: .center) {
         Text(title)
            .byCustomFont(.gmMedium, size: 16.0)
            .frame(maxWidth: .infinity, alignment: .center)
         Spacer.height(16.0)
         
         Text(content)
            .byCustomFont(.gmMedium, size: 15.0)
            .frame(maxWidth: .infinity, alignment: .center)
            .lineSpacing(4.0)
         
         if let buttons {
            Spacer.height(24.0)
            LazyVGrid(
               columns: Array(repeating: GridItem(), count: buttons.count),
               spacing: 16.0
            ) {
               ForEach(buttons, id: \.id) { item in
                  Button {
                     item.action()
                  } label: {
                     RoundedRectangle(cornerRadius: 8.0)
                        .fill(item.background)
                        .overlay {
                           Text(item.title)
                              .byCustomFont(.gmMedium, size: 15.0)
                              .foregroundStyle(item.foreground)
                        }
                  }
                  .frame(height: 48.0)
               }
            }
            
         }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12.0)
      .padding(.horizontal, 16.0)
      .background(.white)
      .clipShape(.rect(cornerRadius: 16.0))
   }
   
   func configurePopup(popup: BottomPopupConfig) -> BottomPopupConfig {
      popup
         .horizontalPadding(20)
         .bottomPadding(42)
         .cornerRadius(16)
   }
}
