//
//  FoldableGroupBox.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

struct FoldableGroupBox<Content>: View where Content: View {
   @State private var isOpen: Bool = false
   private var title: String
   private var content: () -> Content
   
   init(
      title: String,
      content: @escaping () -> Content
   ) {
      self.title = title
      self.content = content
   }
   
   var body: some View {
      GroupBox {
         if isOpen {
            VStack(alignment: .leading) {
               // TODO: some View is here
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
            Button {
               withAnimation(.snappy) {
                  isOpen.toggle()
               }
            } label: {
               withAnimation(.snappy) {
                  Image(systemName: "chevron.down")
                     .rotationEffect(
                        Angle(degrees: isOpen ? 180 : 0)
                     )
                     .foregroundStyle(.baseBlack)
                     
               }
            }
         }
      }
      .clipShape(.rect(cornerRadius: 20.0))
      .padding()
   }
}

#Preview {
   FoldableGroupBox (title: "이게 제목이라고?") {
      Text("이게 된다고?")
   }
}
