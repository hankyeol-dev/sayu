//
//  WriteSayuOn.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import SwiftUI

import MijickNavigationView
import MijickPopupView
import RealmSwift

struct WriteSayuOn: NavigatableView {
   
   private var createdSayuId: ObjectId
   private var isTempSavedModify: Bool
   
   @StateObject
   private var viewLogic: WriteSayuOnViewLogic = .init()
   
   @State
   private var sayuContentHeight: CGFloat = 60.0
   
   @Environment(\.scenePhase)
   private var scenePhase
   @Environment(\.dismiss)
   private var dismissView
   
   init(createdSayuId: ObjectId, isTempSavedModify: Bool) {
      self.createdSayuId = createdSayuId
      self.isTempSavedModify = isTempSavedModify
   }
   
   var body: some View {
      VStack {
         if let sayu = viewLogic.sayu{
            AppNavbar(title: "\(viewLogic.sayuDate)의 사유", 
                      isLeftButton: isTempSavedModify,
                      leftButtonAction: tempSaveModifyDisplayAlert,
                      leftButtonIcon: isTempSavedModify ? .xmark : nil,
                      isRightButton: !isTempSavedModify,
                      rightButtonAction: isTempSavedModify ? nil : tempSaveDisplayAlert,
                      rightButtonIcon: isTempSavedModify ? nil : .saveTemp)
            
            ScrollView(showsIndicators: false) {
               VStack {
                  Spacer.height(12.0)
                  if sayu.timerType == SayuTimerType.timer.rawValue {
                     createTimerView()
                  }
                  
                  if sayu.timerType == SayuTimerType.stopWatch.rawValue {
                     createStopwatchView()
                  }
                  
                  Spacer.height(12.0)
                  createSayuSubjectView(viewLogic.sayuSubject)

                  Spacer.height(12.0)
                  createSayuContentView($viewLogic.sayuContent)
                  
                  
                  if !viewLogic.sayuSubs.isEmpty {
                     Spacer.height(12.0)
                     createSayuSubView()
                  }
                  
                  Spacer.height(12.0)
               }
               .padding(.horizontal, 16.0)
            }
            .background(.basebeige)
            .padding(.vertical, -8.0)
            .frame(maxWidth: .infinity)
            
            Button {
               saveSayu()
            } label: {
               asRoundedRect(
                  title: "오늘의 사유 저장",
                  radius: 8.0,
                  background: .baseGreen,
                  foreground: .white,
                  fontSize: 16.0,
                  font: .gmMedium)
            }
            .padding()
            .background(.basebeige)
            
         } else { EmptyView() }
      }
      .task {
         viewLogic.setSayu(for: createdSayuId)
      }
      .onChange(of: viewLogic.isEarningTodaySayu) { value in
         if value {
            CentreSayuPointAlert(
               title: SayuPointType.EarningCase.dailySayu.rawValue,
               point: SayuPointType.EarningCase.dailySayu.byEarningPoint)
               .showAndStack()
               .dismissAfter(1.0)
            viewLogic.isEarningTodaySayu = false
            pop()
         }
      }
      .onChange(of: viewLogic.isSaved) { value in
         if value {
            successSaveDisplayAlert()
         }
      }
      .onChange(of: viewLogic.isMotionErrorButSaved) { value in
         if value {
            motionErrorButSuccessSaveDisplayAlert()
         }
      }
   }
}

// MARK: - timer & stopwatch
extension WriteSayuOn {
   private func createTimerView() -> some View {
      VStack(spacing: 15.0) {
         ZStack {
            Circle()
               .trim(from: 0.0, to: viewLogic.sayuTimerProgress)
               .stroke(.baseGreen, lineWidth: 10.0)
            
            GeometryReader { proxy in
               let size = proxy.size
               Circle()
                  .fill(.baseGreen)
                  .frame(width: 24, height: 24)
                  .overlay {
                     Circle()
                        .fill(.baseGreenSm)
                        .padding(4.0)
                  }
                  .frame(width: size.width, height: size.height, alignment: .center)
                  .offset(x: size.height / 2)
                  .rotationEffect(.init(degrees: viewLogic.sayuTimerProgress * 360))
            }
            Text(viewLogic.sayuSettingTime.convertTimeToString())
               .byCustomFont(.gmBold, size: 44.0)
               .foregroundStyle(.baseBlack)
               .rotationEffect(.init(degrees: 90.0))
         }
         .padding(12.0)
         .frame(height: 320)
         .rotationEffect(.init(degrees: -90))
         .animation(.easeInOut, value: viewLogic.sayuTimerProgress)
         
         createTimerButtonSet()
         
         if viewLogic.isStopped {
            createTimeTakeItem()
         }
         
         Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .padding(.top, 12.0)
      .background(.white)
      .clipShape(.rect(cornerRadius: 12.0))
      .shadow(color: .grayMd, radius: 1.2, y: 0.3)
      .onChange(of: scenePhase) { phaseStatus in
         if !viewLogic.isPaused {
            if phaseStatus == .background {
               viewLogic.isActiveLastTimeStamp = .init()
            }
            
            if phaseStatus == .active {
               let difference = Date().timeIntervalSince(viewLogic.isActiveLastTimeStamp)
               if (viewLogic.sayuSettingTime - Int(difference)) <= 0 {
                  viewLogic.isPaused = true
                  viewLogic.isStopped = true
                  viewLogic.sayuSettingTime = 0
                  viewLogic.sayuTimerProgress = 1.0
               } else {
                  viewLogic.sayuSettingTime -= Int(difference)
               }
            }
         }
      }
   }
   private func createTimerButtonSet() -> some View {
      HStack {
         Spacer()
         
         if viewLogic.isStopped {
            Button {
               displaySetMoreTimerTimeAlert()
            } label: {
               Image(systemName: "plus")
                  .font(.title3.bold())
                  .foregroundStyle(.white)
                  .frame(width: 48.0, height: 48.0)
                  .background(Circle().fill(.baseGreenLg))
            }
         } else {
            Button {
               if viewLogic.isPaused {
                  viewLogic.startTimer()
               } else {
                  viewLogic.pauseTimer()
               }
            } label: {
               Image(systemName: viewLogic.isPaused ? "play.fill" : "pause" )
                  .font(.title3.bold())
                  .foregroundStyle(.white)
                  .frame(width: 48, height: 48)
                  .background(
                     Circle()
                        .fill(.baseGreen)
                  )
            }
            Spacer.width(36.0)
            
            Button {
               displayStopConfirmAlert()
            } label: {
               Image(systemName: "square.fill")
                  .font(.title3.bold())
                  .foregroundStyle(.white)
                  .frame(width: 48.0, height: 48.0)
                  .background(Circle().fill(.grayXl))
            }
         }
         
         Spacer()
      }
      .frame(maxWidth: .infinity)
   }
   
   private func createStopwatchView() -> some View {
      VStack {
         Spacer.height(12.0)
         
         HStack {
            Spacer()
            Text(viewLogic.sayuSettingTime.convertTimeToString())
               .byCustomFont(.gmBold, size: 56.0)
               .foregroundStyle(.baseBlack)
            Spacer()
         }
         
         Spacer.height(20.0)
         
         HStack {
            let isPaused = viewLogic.isPaused
            
            Button {
               withAnimation(.snappy) {
                  if isPaused {
                     viewLogic.startTimer()
                  } else {
                     viewLogic.pauseTimer()
                  }
               }
            } label: {
               asRoundedRect(
                  title: isPaused ? "다시 사유하기" : "잠시 멈추기",
                  radius: 8.0,
                  background: isPaused ? .baseGreen : .grayMd,
                  foreground: isPaused ? .white : .grayXl,
                  height: 48.0,
                  fontSize: 16.0,
                  font: .gmMedium)
            }
            
            Button {
               viewLogic.pauseTimer()
               displayStopConfirmAlert()
            } label: {
               asRoundedRect(
                  title: "완전 멈추기",
                  radius: 8.0,
                  background: .grayXl,
                  foreground: .white,
                  height: 48.0,
                  fontSize: 16.0,
                  font: .gmMedium)
            }
         }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(.white)
      .clipShape(.rect(cornerRadius: 12.0))
      .shadow(color: .grayMd, radius: 1.2, y: 0.3)
      .onChange(of: scenePhase) { phaseStatus in
         if !viewLogic.isPaused {
            if phaseStatus == .background {
               viewLogic.isActiveLastTimeStamp = .init()
            }
            
            if phaseStatus == .active {
               let difference = Date().timeIntervalSince(viewLogic.isActiveLastTimeStamp)
               viewLogic.sayuSettingTime += Int(difference)
            }
         }
      }
   }
   
   private func createTimeTakeItem() -> some View {
      ScrollView(.horizontal) {
         HStack(alignment: .center, spacing: 8.0) {
            ForEach(viewLogic.sayuTimeTakes.indices, id: \.self) { index in
               let timeTake = viewLogic.sayuTimeTakes[index]
               if timeTake != 0 {
                  HStack {
                     Image(.stopwatch)
                        .resizable()
                        .frame(width: 15.0, height: 15.0)
                     Spacer()
                     Text(timeTake.convertTimeToString())
                        .byCustomFont(.gmlight, size: 12.0)
                  }
                  .padding(.all, 6.0)
                  .background(Capsule().fill(.graySm))
               }
            }
         }
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.horizontal, 16.0)
   }
   
   private func displayStopConfirmAlert() {
      viewLogic.pauseTimer()
      let buttons: [BottomPopupButtonItem] = [
         .init(title: "안 멈출게요", background: .grayMd, foreground: .grayXl, action: {
            viewLogic.startTimer()
            dismiss()
         }),
         .init(title: "네 멈출게요", background: .grayXl, foreground: .grayMd, action: {
            viewLogic.stopTimer()
            UNUserNotificationCenter
               .current()
               .removeAllPendingNotificationRequests()
            dismiss()
         })
      ]
      BottomAlert(title: "사유 시간을 멈춰요", 
                  content: "지금까지 흘러간 시간을 초기화합니다.\n측정된 시간은 임시 저장됩니다.",
                  buttons: buttons)
      .showAndStack()
   }
   
   private func displaySetMoreTimerTimeAlert() {
      BottomAddTimerTimeAlert { time in
         dismiss()
         viewLogic.addTimeSetting(time)
      }
      .showAndStack()
   }
}

extension WriteSayuOn {
   private func createSayuSubjectView(_ subject: String) -> some View {
      return FoldableGroupBox(isOpenButton: false, title: "사유 주제") {
         HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Spacer()
            Text(subject)
               .byCustomFont(.kjcRegular, size: 18.0)
            Spacer()
         }
         .padding(.bottom, 8.0)
      } toggleHandler: { _ in return true }
   }
   
   private func createSayuSubView() -> some View {
      SayuSubCreator(subItems: $viewLogic.sayuSubs, isAddMode: false, contentMode: true)
   }
   
   private func createSayuContentView(_ sayuContent: Binding<String>) -> some View {
      return FoldableGroupBox(isOpenButton: false, title: "구체적인 사유 내용") {
         VStack {
            asRoundedRect(
               title: "최대 1000자까지 작성하실 수 있어요.",
               radius: 16.0,
               background: .basebeige,
               foreground: .grayXl,
               height: 32.0,
               fontSize: 12.0,
               font: .kjcRegular)
            FlexableTextView(text: sayuContent,
                             height: $sayuContentHeight,
                             placeholder: "구체적인 사유 내용을 자유롭게 작성해보세요.",
                             maxHeight: 200.0,
                             maxTextCount: 1000,
                             textFont: .kjcRegular,
                             textSize: 13.0,
                             placeholderColor: .grayXl)
         }
      } toggleHandler: { _ in
         return true
      }
      .frame(minHeight: sayuContentHeight + 160.0, maxHeight: .infinity)
   }
}

extension WriteSayuOn {
   private func tempSaveDisplayAlert() {
      viewLogic.pauseTimer()
      
      let buttons: [BottomPopupButtonItem] = [
         .init(title: "아니요", background: .baseGreen, foreground: .white, action: {
            viewLogic.startTimer()
            dismiss()
         }),
         .init(title: "좋아요", background: .grayMd, foreground: .baseBlack, action: {
            dismiss()
            viewLogic.saveSayu(true)
            if !viewLogic.isSaveError {
               pop(to: Home.self)
            }
         })
      ]
      BottomAlert(title: "오늘의 사유를 잠시 멈출까요?",
                  content: "사유 내용을 안전하게 저장해둘게요.",
                  buttons: buttons)
      .showAndStack()
   }
   
   private func tempSaveModifyDisplayAlert() {
      viewLogic.pauseTimer()
      
      let buttons: [BottomPopupButtonItem] = [
         .init(title: "아니요", background: .baseGreen, foreground: .white, action: {
            viewLogic.startTimer()
            dismiss()
         }),
         .init(title: "네, 괜찮아요", background: .grayMd, foreground: .baseBlack, action: {
            dismiss()
            pop()
         })
      ]
      BottomAlert(title: "정말 작성을 그만두시나요?",
                  content: "같은 사유를 다시 시작하시려면, 다시 포션을 교환해주셔야 해요.",
                  buttons: buttons)
      .showAndStack()
   }
   
   private func successSaveDisplayAlert() {
      let content = "또 하나의 멋진 사유를 해냈어요!"
      CentreSaveSuccessAlert(content: content) {
         dismiss()
         pop()
      }
      .showAndStack()
   }
   
   private func motionErrorButSuccessSaveDisplayAlert() {
      let content = "움직임이 적어 걷기/달리기 데이터는 저장 못했어요!"
      CentreSaveSuccessAlert(content: content) {
         dismiss()
         pop()
      }
      .showAndStack()
   }
   
   private func saveSayu() {
      viewLogic.pauseTimer()
      viewLogic.saveSayu(false)
   }
}
   
