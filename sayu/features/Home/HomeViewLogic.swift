//
//  HomeViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation

final class HomeViewLogic: ObservableObject {
   @Published 
   var selectedTabIndex: Int = 0
   
   @Published
   var onboardingPageIndex: Int = 0
   
   @Published
   var isShowOnboardingView: Bool = UserDefaultsManager.isShowOnboardingView
   
   @Published
   var onboardingItems: [OnboardingViewItem] = []
   
   private let motionManager: MotionManager = .manager
   
   init() {
      setOnboardingContents()
   }
}

extension HomeViewLogic {
   func updateSelectedTabIndex(for index: Int) {
      selectedTabIndex = index
   }
   
   func updateOnboardingIndex() {
      if !checkIsLastIndex()  {
         onboardingPageIndex += 1
      } else {
         motionManager.getAuth()
         UserDefaultsManager.isShowOnboardingView = false
         isShowOnboardingView = false
      }
   }
   
   func checkIsLastIndex() -> Bool {
      return onboardingPageIndex == onboardingItems.count - 1
   }
   
   private func setOnboardingContents() {
      onboardingItems = [
         .init(image: .onboardingTimer,
            title: "사유 시간을 측정해 보세요.",
            contents: "타이머, 스톱워치 방식으로\n내가 사유한 시간을 측정할 수 있어요."),
         .init(image: .onboardingChart,
               title: "사유 내역을 확인해 보세요.",
               contents: "내가 기록한 모든 사유 내역에 대한\n데이터를 확인할 수 있어요."),
         .init(image: .onboardingAuth,
               title: "사유 움직임을 기록해 보세요",
               contents: "동작 및 피트니스 권한을 활성화하면\n걷고, 달리면서 사유한 데이터가 더욱 풍성해져요.")
      ]
   }
}
