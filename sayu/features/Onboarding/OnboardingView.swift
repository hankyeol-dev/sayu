//
//  OnboardingView.swift
//  sayu
//
//  Created by 강한결 on 9/27/24.
//

import SwiftUI

import MijickNavigationView

struct OnboardingView: NavigatableView {
   @ObservedObject private var homeViewLogic: HomeViewLogic
      
   init(homeViewLogic: HomeViewLogic) {
      self.homeViewLogic = homeViewLogic
   }
   
   var body: some View {
      let items = homeViewLogic.onboardingItems
      
      return VStack {
         TabView(selection: $homeViewLogic.onboardingPageIndex) {
            ForEach(0..<items.count, id: \.self) { index in
               createOnboardingContent(items[index])
            }
         }
         .tabViewStyle(.page(indexDisplayMode: .never))
         
         PageIndicator(activePageIndex: homeViewLogic.onboardingPageIndex,
                       numberOfPages: homeViewLogic.onboardingItems.count)
         Spacer.height(36.0)
         Button {
            withAnimation(.easeIn) {
               homeViewLogic.updateOnboardingIndex()               
            }
         } label: {
            asRoundedRect(
               title: homeViewLogic.checkIsLastIndex() ? "슬기로운 사유생활 시작하기" : "확인했어요",
               background: homeViewLogic.checkIsLastIndex() ? .baseGreen : .baseBlack
            )
         }
      }
      .padding(.horizontal, 24.0)
      .padding(.vertical, 64.0)
      .background(.basebeige)
      .animation(.easeInOut(duration: 0.2), value: homeViewLogic.onboardingPageIndex)
   }
}

extension OnboardingView {
   fileprivate func createOnboardingContent(_ item: OnboardingViewItem) -> some View {
      VStack {
         Spacer.height(24.0)
         Image(item.image)
            .aspectRatio(contentMode: .fit)
         Spacer()

         createOnboardingTitle(item.title)
         Spacer.height(24.0)
         
         createOnboardingContents(item.contents)
         Spacer.height(24.0)
      }
   }
   
   fileprivate func createOnboardingTitle(_ title: String) -> some View {
      Text(title)
         .byCustomFont(.gmBold, size: 20.0)
         .frame(maxWidth: .infinity, alignment: .center)
   }
   
   fileprivate func createOnboardingContents(_ contents: String) -> some View {
      let contentsArray = contents.split(separator: "\n")
      return VStack(spacing: 4.0) {
         ForEach(contentsArray, id: \.self) { content in
            Text(content)
               .byCustomFont(.gmMedium, size: 15.0)
               .frame(maxWidth: .infinity, alignment: .center)
         }
      }
   }
}
