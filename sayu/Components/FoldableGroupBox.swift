//
//  FoldableGroupBox.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

struct FoldableGroupBox<Content>: View where Content: View {
   @State private var isOpen: Bool = true
   
   private var isOpenButton: Bool = true
   private var title: String
   private var content: () -> Content
   private var toggleHandler: (Bool) -> Bool
   
   init(
      isOpenButton: Bool = true,
      title: String,
      content: @escaping () -> Content,
      toggleHandler: @escaping (Bool) -> Bool
   ) {
      self.isOpenButton = isOpenButton
      self.title = title
      self.content = content
      self.toggleHandler = toggleHandler
   }
   
   var body: some View {
      GroupBox {
         if isOpen {
            VStack(alignment: .leading) {
               content()
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.vertical, 12.0)
            .padding(.horizontal, 4.0)
         }
      } label: {
         HStack {
            Text(title)
               .byCustomFont(.satoshiMedium, size: 15.0)
            Spacer()
            if isOpenButton {
               Button {
                  withAnimation(.snappy) {
                     isOpen = toggleHandler(isOpen)
                  }
               } label: {
                  withAnimation(.snappy) {
                     Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 10.0, height: 6.0)
                        .rotationEffect(
                           Angle(degrees: isOpen ? 180 : 0)
                        )
                        .foregroundStyle(.baseBlack)
                        .padding(.trailing, 8.0)
                     
                  }
               }
            }
         }
      }
      .clipShape(.rect(cornerRadius: 20.0))
   }
}
