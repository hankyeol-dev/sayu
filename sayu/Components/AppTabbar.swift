//
//  AppTabbar.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

struct AppTabbar: View {
   
   @Binding var selectedTabIndex: Int
   @State var isDisplayWriteView: Bool = false
   
   private enum TabIcons: Int, CaseIterable {
      case calendar
      case plus
      case chart
      
      var byUnselected: Image {
         switch self {
         case .calendar:
               .init(.calendarUnSelected)
         case .chart:
               .init(.chartUnSelected)
         case .plus:
               .init(.plusSelected)
         }
      }
      
      var bySelected: Image {
         switch self {
         case .calendar:
               .init(.calendarSelected)
         case .chart:
               .init(.chartSelected)
         case .plus:
               .init(.plusSelected)
         }
      }
   }
     
   var body: some View {
      HStack(alignment: .center) {
         ForEach(TabIcons.allCases, id: \.self.rawValue) { icon in
            Spacer()
            
            if icon.rawValue == 1 {
               createTab(icon) {
                  selectedTabIndex = icon.rawValue
                  isDisplayWriteView = true
               }
               .fullScreenCover(isPresented: $isDisplayWriteView) {
                  WriteSayu()
               }
            } else {
               createTab(icon) {
                  selectedTabIndex = icon.rawValue
               }
            }
            
            Spacer()
         }
      }
      .padding(.vertical, 16.0)
      .frame(maxWidth: .infinity, maxHeight: 56.0)
      .background(.grayXs)
      .shadow(color: .graySm, radius: 1, y: -0.5)
      .ignoresSafeArea()
   }
   
   private func createTab(_ tabIcon: TabIcons, action: @escaping () -> Void) -> some View {
      Button {
         action()
      } label: {
         if selectedTabIndex == tabIcon.rawValue {
            tabIcon.bySelected
               .resizable()
               .frame(width: 32, height: 32)
         } else {
            tabIcon.byUnselected
               .resizable()
               .frame(width: 32, height: 32)
         }
      }
   }
}
