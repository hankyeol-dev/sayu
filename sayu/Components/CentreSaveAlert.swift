//
//  CentreSayuPointAlert.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import SwiftUI

import MijickPopupView

struct CentreSayuPointAlert: CentrePopup {
   
   func createContent() -> some View {
      VStack(alignment: .center) {
         Spacer.height(16.0)
         
         Image(.sayuPoint)
            .resizable()
            .frame(width: 48.0, height: 48.0)
         
         Spacer.height(12.0)
         
         Text("오늘의 사유 작성")
            .byCustomFont(.gmMedium, size: 16.0)
         
         Spacer.height(8.0)
         
         HStack(alignment: .bottom) {
            Text("3")
               .byCustomFont(.gmBold, size: 24.0)
            Text("사유 포인트")
               .byCustomFont(.gmBold, size: 20.0)
         }
         
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
   }
}
