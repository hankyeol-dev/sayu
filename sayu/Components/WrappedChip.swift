//
//  WrappedChip.swift
//  sayu
//
//  Created by 강한결 on 9/24/24.
//

import SwiftUI

struct WrappedChip: View {
   private let chips: [String]
   private var chipsAction: ((Int) -> Void)
   
   init(
      chips: [String],
      chipsAction: @escaping (Int) -> Void
   ) {
      self.chips = chips
      self.chipsAction = chipsAction
   }
   
   var body: some View {
      let verticalInset = 8.0
      let horizontalInset = 8.0
      var width: CGFloat = .zero
      var height: CGFloat = .zero
      
      return GeometryReader { proxy in
         ZStack(alignment: .topLeading) {
            ForEach(chips.indices, id: \.self) { index in
               let item = chips[index]
               createChipView(item)
                  .alignmentGuide(.leading) { dimension in
                     if (abs(width - dimension.width)) > proxy.size.width {
                        width = 0
                        height -= dimension.height
                        height -= verticalInset
                     }
                     
                     let result = width
                     if index == chips.count - 1 {
                        width = 0
                     } else {
                        width -= horizontalInset
                        width -= dimension.width
                     }
                     
                     return result
                  }
                  .alignmentGuide(.top) { dimesion in
                     let result = height
                     if index == chips.count - 1 {
                        height = 0
                     }
                     return result
                  }
                  .onTapGesture {
                     chipsAction(index)
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
         .padding(.horizontal, 12.0)
         .padding(.vertical, 8.0)
         .background(
            Capsule().foregroundStyle(.white)
         )
   }
}
