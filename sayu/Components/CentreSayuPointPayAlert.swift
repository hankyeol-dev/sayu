//
//  CentreSayuPointPayAlert.swift
//  sayu
//
//  Created by 강한결 on 9/26/24.
//

import SwiftUI

import MijickPopupView

struct CentreSayuPointPayAlert: CentrePopup {
   
   private let isConfirm: Bool
   private let content: String
   private let point: Int
   private let confirmAction: (Int) -> Void
   
   init(
      isConFirm: Bool,
      content: String,
      point: Int,
      confirmAction: @escaping (Int) -> Void
   ) {
      self.isConfirm = isConFirm
      self.content = content
      self.point = point
      self.confirmAction = confirmAction
   }
   
   func createContent() -> some View {
      VStack(alignment: .center) {
         
         if isConfirm {
            Image(.redPotion)
               .resizable()
               .frame(width: 48.0, height: 48.0)
            
            Spacer.height(15.0)
            
            Text(content)
               .byCustomFont(.gmMedium, size: 15.0)
               .foregroundStyle(.baseBlack)
               .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer.height(15.0)
            
            LazyVGrid(
               columns: Array(repeating: GridItem(), count: 2)) {
                  Button {
                     dismiss()
                  } label: {
                     asRoundedRect(
                        title: "괜찮아요.",
                        radius: 12.0,
                        background: .grayMd,
                        foreground: .grayXl,
                        height: 40.0,
                        fontSize: 15.0,
                        font: .gmMedium
                     )
                  }
                  
                  Button {
                     dismiss()
                     confirmAction(point)
                  } label: {
                     RoundedRectangle(cornerRadius: 12.0)
                        .fill(.baseBlack)
                        .overlay {
                           HStack(alignment: .center) {
                              Spacer()
                              Image(.sayuPoint)
                                 .resizable()
                                 .frame(width: 15.0, height: 15.0)
                              Spacer.width(8.0)
                              Text("- " + String(point))
                                 .byCustomFont(.gmMedium, size: 15.0)
                                 .foregroundStyle(.error)
                              Spacer()
                           }
                        }
                        .frame(height: 40.0)
                  }
               }
         }
         
         else {
            Text(content)
               .byCustomFont(.gmMedium, size: 15.0)
               .foregroundStyle(.baseBlack)
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
