//
//  SayuPointView.swift
//  sayu
//
//  Created by 강한결 on 9/23/24.
//

import SwiftUI

import MijickNavigationView
import MijickPopupView

struct SayuPointView: NavigatableView {
   
   @EnvironmentObject
   var pointManager: SayuPointManager
   
   @AppStorage(AppEnvironment.UserDefaultsKeys.isShowAppDeleteNotikey.rawValue)
   private var isShowAppDeleteNoti = UserDefaultsManager.isShowSayuPointDeleteNoti
  
   func configure(view: NavigationConfig) -> NavigationConfig {
      view.navigationBackGesture(.drag)
   }
   
   var body: some View {
      VStack {
         AppMainNavbar {
            createLeftButton()
         } rightButton: {
            Text("")
         }
         ScrollView(showsIndicators: false) {
            VStack {
               if !isShowAppDeleteNoti {
                  createInitialNoti()
                  Spacer.height(32.0)
               }
               
               createDailySayuPointSection()
               Spacer.height(32.0)
               
               createLatestSayuPointList()
            }
            .padding(.horizontal, 16.0)
         }
         .padding(.top, -8.0)
      }
      .background(.basebeige)
      .onChange(of: pointManager.isSayuPointError) { isError in
         if isError {
            displayErrorAlert()
         }
      }
      .task {
         pointManager.mappingDailyEarningButtonList()
      }
   }
}

extension SayuPointView {
   private func createLeftButton() -> some View {
      Button {
         pop()
      } label: {
         Image(.arrowBack)
            .resizable()
            .frame(width: 16.0, height: 8.0)
      }
   }
   
   private func createInitialNoti() -> some View {
      ZStack {
         HStack {
            Spacer()
            Button {
               isShowAppDeleteNoti = true
            } label: {
               Image(.xmark)
                  .resizable()
                  .frame(width: 10.0, height: 10.0)
            }
            .frame(alignment: .trailing)
         }
         .padding(.trailing, 8.0)
         
         VStack {
            Text("슬기로운 사유생활 앱을 삭제하면")
               .byCustomFont(.gmMedium, size: 15.0)
               .foregroundStyle(.grayXl)
            Spacer.height(4.0)
            Text("포인트는 초기화 되어요.")
               .byCustomFont(.gmMedium, size: 15.0)
               .foregroundStyle(.grayXl)
         }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(
         RoundedRectangle(cornerRadius: 12.0)
            .fill(.graySm)
      )
   }
   
   private func createDailySayuPointSection() -> some View {
      return VStack {
         HStack(alignment: .center, spacing: 8.0) {
            Text("오늘의 사유 포인트 받아가기")
               .byCustomFont(.dos, size: 15.0)
               .foregroundStyle(.baseBlack)
            Image(.sayuPoint)
               .resizable()
               .frame(width: 16.0, height: 14.0)
            Spacer()
         }
         Spacer.height(12.0)
         VStack {
            ForEach(pointManager.dailySayuPointButtonList, id: \.id) { button in
               HStack {
                  Text(button.title)
                     .byCustomFont(.gmMedium, size: 16.0)
                     .foregroundStyle(.grayXl)
                  
                  Spacer()
                  
                  Button {
                     displayGetDailyPointAlert(button)
                     pointManager.touchDailyEarningButton(button)
                  } label: {
                     RoundedRectangle(cornerRadius: 8.0)
                        .fill( 
                           (button.canEarned && !button.isEarned) 
                           ? .baseBlack
                           : .grayMd
                        )
                        .overlay {
                           HStack(alignment: .center) {
                              Spacer()
                              Image(.sayuPoint)
                                 .resizable()
                                 .frame(width: 20.0, height: 20.0)
                              Spacer.width(8.0)
                              Text(String(button.point))
                                 .byCustomFont(.gmMedium, size: 14.0)
                                 .foregroundStyle(
                                    (button.canEarned && !button.isEarned)
                                    ? .white
                                    : .graySm
                                 )
                              Spacer()
                           }
                        }
                        .frame(width: 64.0, height: 36.0)
                  }
                  .disabled(!button.canEarned || button.isEarned)
               }
               .padding()
               .background(
                  RoundedRectangle(cornerRadius: 12.0)
                     .fill(.white)
               )
            }
         }
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
   }
   
   private func createLatestSayuPointList() -> some View {
      VStack {
         HStack(alignment: .center, spacing: 8.0) {
            Text("포인트 획득/차감 내역 (최근 10개)")
               .byCustomFont(.dos, size: 15.0)
               .foregroundStyle(.baseBlack)
            Image(.folder)
               .resizable()
               .frame(width: 14.0, height: 12.0)
            Spacer()
         }
         
         Spacer.height(12.0)
         
         VStack(spacing: 16.0) {
            ForEach(pointManager.getLastTenRecords(), id: \._id) { record in
               HStack(alignment: .center) {
                  Text(record.createdAt.formattedForView())
                     .byCustomFont(.gmlight, size: 13.0)
                     .foregroundStyle(.grayXl)
                  Spacer()
                  Text(record.descript)
                     .byCustomFont(.gmlight, size: 15.0)
                     .foregroundStyle(.baseBlack)
                  Spacer.width(8.0)
                  Text(record.pointType == 0 ? "+ \(String(record.point))" : "- \(String(record.point))")
                     .byCustomFont(.gmlight, size: 15.0)
                     .foregroundStyle(record.pointType == 0 ? .baseGreen : .errorSm)
               }
               .padding(.horizontal, 4.0)
            }
         }
         .padding()
         .background(
            RoundedRectangle(cornerRadius: 12.0)
               .fill(.white)
         )
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
   }
}

extension SayuPointView {
   private func displayGetDailyPointAlert(_ item: SayuPointEarningButtonItem) {
      CentreSayuPointAlert(title: item.title, point: item.point)
         .showAndStack()
         .dismissAfter(1.0)
   }
   private func displayErrorAlert() {
      BottomAlert(
         title: "포인트 적립에 문제가 있어요",
         content: "포인트 적립/차감에 잠깐 문제가 발생했어요.\n지금까지 획득한 포인트에는 문제가 없어요.\n잠시 후 다시 시도해주세요.",
         buttons: [
            .init(title: "알겠어요", background: .baseGreen, foreground: .white, action: {
               dismiss()
               pop()
            })
         ])
      .showAndStack()
   }
}
