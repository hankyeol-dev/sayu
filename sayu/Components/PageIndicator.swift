//
//  PageIndicator.swift
//  sayu
//
//  Created by 강한결 on 9/27/24.
//

import SwiftUI

struct PageIndicator: View {
   private let activePageIndex: Int
   private let numberOfPages: Int
   
   init(activePageIndex: Int, numberOfPages: Int) {
      self.activePageIndex = activePageIndex
      self.numberOfPages = numberOfPages
   }
   
   var body: some View {
      HStack(spacing: 9) {
         ForEach(0..<numberOfPages, id: \.self, content: createItem)
      }
      .animation(animation, value: activePageIndex)
   }
}

private extension PageIndicator {
   func createItem(_ index: Int) -> some View {
      Circle()
         .fill(colour[index == activePageIndex]!)
         .frame(width: 10.0, height: 10.0)
   }
}

private extension PageIndicator {
   var colour: [Bool: Color] {[ true: .baseGreen, false: .graySm ]}
   var animation: Animation { .easeInOut(duration: 0.2) }
}
