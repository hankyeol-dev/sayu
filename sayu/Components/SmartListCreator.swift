//
//  SmartListCreator.swift
//  sayu
//
//  Created by 강한결 on 9/21/24.
//

import SwiftUI
import MCEmojiPicker

struct SmartListCreator: View {
   @State private var isOpen: Bool = false
   @State private var smartListFieldText: String = ""
   @FocusState private var smartListfieldFocus: Bool
   @Binding var smartListIcon: String
   @Binding var smartLists: [String]
   
   var body: some View {
      VStack {
         HStack(alignment: .center, spacing: 8.0) {
            Button {
               withAnimation(.snappy) {
                  isOpen.toggle()
               }
            } label: {
               RoundedRectangle(cornerRadius: 8.0)
                  .fill(.white)
                  .frame(width: 40.0, height: 40.0)
                  .overlay {
                     Text(smartListIcon)
                  }
            }.emojiPicker(
               isPresented: $isOpen,
               selectedEmoji: $smartListIcon,
               arrowDirection: .up,
               customHeight: 300.0
            )
            
            RoundedTextField(
               fieldText: $smartListFieldText,
               placeholder: "사유 목록을 등록해보세요.",
               font: .gmMedium,
               fontSize: 13.0
            )
               .focused($smartListfieldFocus)
               .disabled(smartLists.count >= 3)
               .onSubmit {
                  smartListfieldFocus = false
               }
         }
         
         Button {
            if !smartListFieldText.isEmpty, smartLists.count < 3 {
               smartLists.append("\(smartListIcon) \(smartListFieldText)")
               smartListFieldText = ""
               smartListfieldFocus = false
            }
         } label: {
            asRoundedRect(title: "생성",
                          background: smartListFieldText.isEmpty ? .graySm : .baseGreen,
                          foreground: smartListFieldText.isEmpty ? .grayXl : .white)
         }
         .disabled(smartLists.count >= 3)
         
         
         if !smartLists.isEmpty {
            Spacer.height(12.0)
            createChipListview(smartLists)
         }
      }
   }
   
   private func createChipListview(_ items: [String]) -> some View {
      let verticalInset = 8.0
      let horizontalInset = 8.0
      var width: CGFloat = .zero
      var height: CGFloat = .zero
      return GeometryReader { proxy in
         ZStack(alignment: .topLeading) {
            ForEach(items.indices, id: \.self) { index in
               let item = items[index]
               createChipView(item)
                  .alignmentGuide(.leading) { dimension in
                     if (abs(width - dimension.width)) > proxy.size.width {
                        width = 0
                        height -= dimension.height
                        height -= verticalInset
                     }
                     
                     let result = width
                     if index == items.count - 1 {
                        width = 0
                     } else {
                        width -= horizontalInset
                        width -= dimension.width
                     }
                     
                     return result
                  }
                  .alignmentGuide(.top) { dimesion in
                     let result = height
                     if index == items.count - 1 {
                        height = 0
                     }
                     return result
                  }
                  .onTapGesture {
                     smartLists.remove(at: index)
                  }
            }
         }
      }
      .frame(height: 48.0)
      .frame(maxWidth: .infinity)
   }
   
   private func createChipView(_ item: String) -> some View {
      Text(item)
         .byCustomFont(.gmMedium, size: 13.0)
         .foregroundStyle(.baseBlack)
         .padding(.horizontal, 12.0)
         .padding(.vertical, 8.0)
         .background(
            Capsule().fill(.white)
         )
   }
}
