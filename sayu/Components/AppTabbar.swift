//
//  AppTabbar.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

import MijickNavigationView
import RealmSwift

struct AppTabbar: NavigatableView {
   
   @Binding var selectedTabIndex: Int
   @State var isDisplayWriteView: Bool = false
   @State var isDisplayWriteOnView: Bool = false
   @State var createdSayuId: ObjectId? = nil
   
   private enum TabIcons: Int, CaseIterable {
      case calendar
      case plus
      case chart
      
      var byUnselected: Image {
         switch self {
         case .calendar:
               .init(.calendarPixeledUnselected)
         case .chart:
               .init(.chartPixeledUnselected)
         case .plus:
               .init(.plusPixeledSelectedTint)
         }
      }
      
      var bySelected: Image {
         switch self {
         case .calendar:
               .init(.calendarPixeledSelectedTint)
         case .chart:
               .init(.chartPixeledSelectedTint)
         case .plus:
               .init(.plusPixeledSelectedTint)
         }
      }
   }
     
   var body: some View {
      HStack(alignment: .center) {
         
         Spacer()
         createTab(TabIcons.calendar) {
            selectedTabIndex = TabIcons.calendar.rawValue
         }
         Spacer()
         
         Spacer()
         Button {
            isDisplayWriteView = true
         } label: {
            TabIcons.plus.bySelected
               .resizable()
               .frame(width: 32, height: 32)
         }
         .fullScreenCover(isPresented: $isDisplayWriteView)  {
            var coverView = WriteSayu(date: .now)
            coverView.disappearHandler = { sayuId in
               if let sayuId {
                  self.createdSayuId = sayuId
                  isDisplayWriteOnView = true
               } else {
                  isDisplayWriteOnView = false
               }
            }
            return coverView
         }
         Spacer()
         
         Spacer()
         createTab(TabIcons.chart) {
            selectedTabIndex = TabIcons.chart.rawValue
         }
         Spacer()
         
      }
      .padding(.vertical, 16.0)
      .frame(maxWidth: .infinity, maxHeight: 56.0)
      .background(.basebeige)
      .shadow(color: .graySm, radius: 1, y: -0.5)
      .onChange(of: isDisplayWriteOnView) { isOn in
         if isOn, let createdSayuId {
            WriteSayuOn(createdSayuId: createdSayuId)
               .push(with: .horizontalSlide)
            isDisplayWriteOnView = false
         }
      }
   }
   
   private func createTab(_ tabIcon: TabIcons, action: @escaping () -> Void) -> some View {
      Button {
         action()
      } label: {
         if selectedTabIndex == tabIcon.rawValue {
            tabIcon.bySelected
               .resizable()
               .frame(width: 24.0, height: 24.0)
         } else {
            tabIcon.byUnselected
               .resizable()
               .frame(width: 24.0, height: 24.0)
         }
      }
   }
}
