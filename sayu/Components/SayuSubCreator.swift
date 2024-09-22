//
//  SayuSubCreator.swift
//  sayu
//
//  Created by 강한결 on 9/20/24.
//

import SwiftUI

struct SayuSubCreator: View {
   
   private enum SubFieldFocus: Int {
      case first, second, third, forth, fifth, sixth
   }
   
   private enum SubContentFocus: Int {
      case first, second, third, forth, fifth, sixth
   }
   
   @FocusState
   private var fieldFocus: SubFieldFocus?
   @FocusState
   private var textViewFocus: SubContentFocus?
   
   @Binding
   var subItems: [SubViewItem]
   
   @State
   private var subContents: [String] = []
   
   @State
   var isAddMode: Bool
   @State
   var contentMode: Bool
   @State
   private var textViewHeight: CGFloat = 40.0
    
   var body: some View {
      FoldableGroupBox(title: "함께 사유할 내용") {
         VStack(spacing: 16.0) {
            ForEach(subItems.indices, id: \.self) { index in
               createSubField($subItems[index], index: index)
            }
            if isAddMode && subItems.count < 6 {
               Button {
                  withAnimation(.easeInOut) {
                     addSubItem()
                  }
               } label: {
                  asRoundedRect(
                     title: "추가하기",
                     radius: 8.0,
                     background: .grayMd,
                     foreground: .grayXl,
                     height: 32.0,
                     fontSize: 15.0,
                     font: .satoshiMedium)
               }
            }
         }
      } toggleHandler: { isNotOpen in
         if isNotOpen {
            if fieldFocus == nil && textViewFocus == nil {
               return false
            } else {
               return true
            }
         } else {
            return true
         }
      }
   }
   
}

extension SayuSubCreator {
   private func createSubField(_ item: Binding<SubViewItem>, index: Int) -> some View {
      VStack {
         HStack(alignment: .center, spacing: 8.0) {
            RoundedTextField(
               fieldText: item.sub,
               placeholder: "함께 사유할 내용을 입력해주세요.",
               font: .kjcRegular,
               fontSize: 13.0,
               tint: .grayXl,
               background: .grayXs,
               foregroud: .grayXl,
               borderWidth: 0.5,
               height: 36)
            .focused($fieldFocus, equals: SubFieldFocus.init(rawValue: index))
            .onSubmit {
               fieldFocus = nil
            }
            .disabled(contentMode)
         }
         
         if contentMode {
            FlexableTextView(
               text: item.content,
               height: $textViewHeight,
               placeholder: "떠오르는 생각을 자유롭게 작성해보세요.",
               maxHeight: 100.0,
               textFont: .kjcRegular,
               textSize: 13.0,
               placeholderColor: .grayMd
            )
            .focused($textViewFocus, equals: SubContentFocus.init(rawValue: index))
            .onSubmit {
               textViewFocus = nil
            }
         }
      }
      .frame(minHeight: textViewHeight + 100.0, maxHeight: .infinity)
   }
   
   
   private func addSubItem() {
      subItems.append(.init(sub: "", content: ""))
   }
}

