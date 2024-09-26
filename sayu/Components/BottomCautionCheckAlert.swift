//
//  BottomCautionCheckAlert.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import SwiftUI
import MijickPopupView

struct CautionItem: Identifiable, Hashable {
   let id: UUID = .init()
   var content: String
   var isChecked: Bool = false
}

struct BottomCautionCheckAlert: BottomPopup {
   private var title: String
   private var content: String
   private var confirmButtonTitle: String

   @State var cautions: [CautionItem] = []
   private var confirmHandler: () -> Void
   
   init(
      title: String,
      content: String,
      cautions: [CautionItem],
      confirmButtonTitle: String,
      confirmHandler: @escaping () -> Void
   ) {
      self.title = title
      self.content = content
      self.cautions = cautions
      self.confirmButtonTitle = confirmButtonTitle
      self.confirmHandler = confirmHandler
   }
   
   func createContent() -> some View {      
      VStack(alignment: .center) {
         Text(title)
            .byCustomFont(.gmMedium, size: 16.0)
         Spacer.height(16.0)
         
         Text(content)
            .byCustomFont(.gmMedium, size: 15.0)
            .lineSpacing(6.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12.0)
         Spacer.height(16.0)
                  
         VStack {
            ForEach(cautions.indices, id: \.self) { index in
               let caution = cautions[index]
               let valid = caution.isChecked
               RoundedRectangle(cornerRadius: 8.0)
                  .stroke(valid ? .baseGreen : .grayLg, lineWidth: valid ? 1.5 : 0.8)
                  .clipShape(.rect(cornerRadius: 8.0))
                  .overlay {
                     HStack(alignment: .center) {
                        Spacer.width(12.0)
                        Text(caution.content)
                           .byCustomFont(.gmMedium, size: 15.0)
                           .foregroundStyle(valid ? .baseGreen : .grayLg)
                           .lineSpacing(4.0)
                        Spacer()
                        Image(valid ? .checked : .unChecked)
                           .resizable()
                           .frame(width: 16.0, height: 16.0)
                           .foregroundStyle(valid ? .baseGreenLg : .grayLg)
                        Spacer.width(12.0)
                     }
                  }
                  .frame(height: 52.0)
                  .onTapGesture {
                     withAnimation(.snappy) {
                        cautions[index].isChecked.toggle()
                     }
                  }
            }
         }
         .padding(.horizontal, 12.0)
         
         Spacer.height(12.0)
         
         Button {
            confirmHandler()
         } label: {
            asRoundedRect(
               title: confirmButtonTitle,
               radius: 8.0,
               background: validAllCautionChecked() ? .baseGreen : .grayMd,
               foreground: validAllCautionChecked() ? .white : .grayXl,
               height: 48.0,
               fontSize: 15.0,
               font: .gmMedium)
         }
         .disabled(!validAllCautionChecked())
         .padding(.horizontal, 12.0)
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.vertical, 12.0)
      .padding(.horizontal, 16.0)
      .background(.white)
      .clipShape(.rect(cornerRadius: 16.0))
   }
   
   private func validAllCautionChecked() -> Bool {
      withAnimation(.snappy) {
         return cautions.filter({ $0.isChecked }).count == cautions.count
      }
   }
}
