//
//  CentreEmptySayuAlert.swift
//  sayu
//
//  Created by 강한결 on 9/23/24.
//

import SwiftUI

import MijickPopupView

struct CentreEmptySayuAlert: CentrePopup {
   
   func createContent() -> some View {
      VStack(alignment: .center) {
         Spacer.height(16.0)
         
         Image(.notfound)
            .resizable()
            .frame(width: 33.0, height: 28.0)
         
         Spacer.height(12.0)
         
         Text("사유를 찾을 수 없어요 🥹")
            .byCustomFont(.gmMedium, size: 20.0)
         
         Spacer.height(16.0)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(.white)
      .clipShape(.rect(cornerRadius: 16.0))
   }
   
   func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
      popup
         .horizontalPadding(16.0)
         .tapOutsideToDismiss(true)
   }
}

#Preview {
   CentreEmptySayuAlert()
}
