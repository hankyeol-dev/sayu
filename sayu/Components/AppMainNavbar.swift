//
//  AppMainNavbar.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import SwiftUI

struct AppMainNavbar: View {
   private var point: Int
   
   init(point: Int) {
      self.point = point
   }
   
   var body: some View {
      HStack(alignment: .center) {
         Spacer.width(16.0)
         Button {
            
         } label: {
            HStack(alignment: .center) {
               Image(.sayuPoint)
                  .resizable()
                  .frame(width: 20.0, height: 20.0)
               Spacer.width(4.0)
               Text(String(point))
                  .byCustomFont(.gmMedium, size: 13.0)
                  .foregroundStyle(.grayXl)
            }
         }
         
         Spacer()
      }
      .padding(.vertical, 12.0)
      .frame(maxHeight: 48.0)
      .frame(maxWidth: .infinity)
      .background(.basebeige)
      .shadow(color: .graySm, radius: 1.0, y: 0.5)
   }
}
