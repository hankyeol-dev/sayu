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
            .byCustomFont(.satoshiMedium, size: 16.0)
         
         Spacer.height(16.0)
         
         Text(content)
            .byCustomFont(.satoshiRegular, size: 13.0)
         
         Spacer.height(12.0)
                  
         VStack {
            ForEach(cautions.indices, id: \.self) { index in
               let caution = cautions[index]
               let valid = caution.isChecked
               RoundedRectangle(cornerRadius: 8.0)
                  .stroke(valid ? .baseGreenLg : .grayLg, lineWidth: valid ? 1.5 : 0.8)
                  .clipShape(.rect(cornerRadius: 8.0))
                  .overlay {
                     HStack(alignment: .center) {
                        Spacer.width(12.0)
                        Text(caution.content)
                           .byCustomFont(.satoshiRegular, size: 13.0)
                           .foregroundStyle(valid ? .baseGreenLg : .grayLg)
                        Spacer()
                        Image(valid ? .checked : .unChecked)
                           .resizable()
                           .frame(width: 16.0, height: 16.0)
                           .foregroundStyle(valid ? .baseGreenLg : .grayLg)
                        Spacer.width(12.0)
                     }
                  }
                  .frame(height: 48)
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
               background: validAllCautionChecked() ? .baseGreenLg : .grayMd,
               foreground: validAllCautionChecked() ? .white : .grayXl,
               height: 48.0,
               fontSize: 15.0,
               font: .satoshiMedium)
         }
         .disabled(!validAllCautionChecked())
         .padding(.horizontal, 12.0)
      }
      .frame(maxWidth: .infinity)
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

#Preview {
   let cautions: [CautionItem] = [
      .init(content: "걷거나 달리는 중에는 주변을 잘 살펴주세요."),
      .init(content: "중요한 생각이 떠오르면 제자리에 멈춰서 작성해주세요."),
   ]
   
   return BottomCautionCheckAlert(
      title: "꼭 확인해주세요.",
      content: "걷거나 달리면서 사유하시는군요 👍\n안전하고 건강한 사유를 위해 아래의 내용을 반드시 확인해주세요.",
      cautions: cautions,
      confirmButtonTitle: "사유 시작") {
         print("confirm")
      }
      .showAndStack()
}
