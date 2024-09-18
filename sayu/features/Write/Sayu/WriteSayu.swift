//
//  WriteSayu.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI
import MijickNavigationView
import MijickPopupView

struct WriteSayu: NavigatableView {
   @Environment(\.dismiss) private var popOutView
   
   func configure(view: NavigationConfig) -> NavigationConfig {
      view.navigationBackGesture(.drag)
   }
   
   var body: some View {
      VStack {
         AppNavbar(title: "오늘의 사유",
                   isLeftButton: true,
                   leftButtonAction: dismissView,
                   leftButtonIcon: .arrowBack,
                   isRightButton: false)

         ScrollView {
            
         }
         .background(.white)
         .frame(maxWidth: .infinity)
         .padding(.horizontal, 16.0)
         
         Spacer()
         
         Button {
            
         } label: {
            RoundedRectangle(cornerRadius: 8.0)
               .fill(.baseGreen)
               .overlay {
                  Text("사유하기")
                     .byCustomFont(.satoshiBold, size: 15.0)
                     .bold()
                     .foregroundStyle(.white)
               }
               .frame(height: 40)
         }
         .frame(maxWidth: .infinity)
         .padding()
         .background(.grayLg)
      }
      .implementPopupView()
   }
}

extension WriteSayu {
   private func dismissView() {
      let buttons: [BottomPopupButtonItem] = [
         .init(title: "취소", background: .graySm, foreground: .grayXl, action: dismiss),
         .init(title: "확인", background: .error, foreground: .white, action: dismissAndPopOut)
      ]
      BottomAlert(title: "작성을 중단하시나요?", content: "확인을 터치하시면 지금까지 작성하신 내용이 저장되지 않습니다.", buttons: buttons)
         .showAndStack()
   }
   
   private func dismissAndPopOut() {
      dismiss()
      popOutView()
   }
}
