//
//  CentreSaveSuccessAlert.swift
//  sayu
//
//  Created by 강한결 on 9/26/24.
//

import SwiftUI

import MijickPopupView

struct CentreSaveSuccessAlert: CentrePopup {
   
   private let content: String
   private let confirmAction: () -> Void
   
   init(content: String, confirmAction: @escaping () -> Void) {
      self.content = content
      self.confirmAction = confirmAction
   }
   
   func createContent() -> some View {
      VStack(alignment: .center) {
         
         Image(.launch)
            .resizable()
            .frame(width: 36.0, height: 36.0)
         
         Spacer.height(12.0)
         
         Text(content)
            .byCustomFont(.gmMedium, size: 15.0)
         
         Spacer.height(16.0)
         
         Button {
            confirmAction()
         } label: {
            asRoundedRect(
               title: "확인",
               radius: 12.0,
               background: .baseGreen,
               foreground: .white,
               height: 40.0,
               fontSize: 15.0,
               font: .gmMedium)
         }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(.white)
      .clipShape(.rect(cornerRadius: 16.0))
   }
   
   func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
      popup
         .horizontalPadding(16.0)
   }
}
