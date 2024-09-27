//
//  WriteSayu.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

import MijickNavigationView
import MijickPopupView
import RealmSwift

struct WriteSayu: NavigatableView {
   private var date: Date
   var disappearHandler: ((ObjectId?) -> Void)?
   
   @Environment(\.dismiss)
   private var popOutView
   
   @StateObject
   private var viewLogic: WriteSayuViewLogic = .init()
   
   @FocusState
   private var subjectFieldFocus: Bool
   @FocusState
   private var subFieldFocus: WriteSayuViewLogic.SubFieldFocus?
   
   init(date: Date) {
      self.date = date
   }
   
   var body: some View {
      VStack {
         // MARK: 상단 네비게이션 영역
         AppNavbar(title: "\(viewLogic.writeDateForView)의 사유",
                   isLeftButton: true,
                   leftButtonAction: dismissView,
                   leftButtonIcon: .arrowBack,
                   isRightButton: false)
         
         // MARK: 사유하기 설정 영역
         ScrollView(.vertical, showsIndicators: false) {
            VStack {
               Spacer.height(12.0)
               
               createSubjectView()
               Spacer.height(12.0)
               
               createSubView()
               Spacer.height(12.0)
               
               createSayuTypeView()
               Spacer.height(12.0)
               
               createSayuTimer()
               Spacer.height(12.0)
               
               createSayuSmartList()
               Spacer.height(12.0)
            }
            .padding(.horizontal, 16.0)
         }
         .background(.basebeige)
         .padding(.vertical, -8.0)
         .frame(maxWidth: .infinity)
         
         Spacer()
         
         Button {
            if viewLogic.selectedSayuType == .run || viewLogic.selectedSayuType == .walk {
               popAlertCheckCaution()
            } else {
               viewLogic.writeSayu()
               if viewLogic.createdSayuId != nil {
                  popOutView()
               }
            }
         } label: {
            asRoundedRect(
               title: "사유하기",
               radius: 8.0,
               background: .baseGreen,
               foreground: .white,
               fontSize: 15.0,
               font: .gmMedium)
         }
         .padding()
         .background(.basebeige)
      }
      .implementPopupView { config in
         config.bottom { bottom in
            bottom.tapOutsideToDismiss(true)
         }
      }
      .task {
         viewLogic.setDate(date)
      }
      .onChange(of: viewLogic.isWriteValid) { valid in
         if valid == .needToSetSubject {
            popAlertCheckSubject()
         }
         
         if valid == .needToSetTime {
            popAlertCheckTimer()
         }
      }
      .onDisappear {
         disappearHandler?(viewLogic.createdSayuId)
      }
   }
}

extension WriteSayu {
   private func createSystemSubjectSelection(_ items: [SubjectViewItem]) -> some View {
      LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
         ForEach(items, id: \.id) { item in
            
            let valid = viewLogic.selectedSystemSubject == item
            
            Button {
               withAnimation(.snappy) {
                  if valid {
                     viewLogic.setSystemSubItems(nil)
                  } else {
                     viewLogic.setSystemSubItems(item)
                  }
               }
            } label: {
               asRoundedRect(title: item.subject,
                             radius: 10.0,
                             background: valid ? .baseGreen : .graySm,
                             foreground: valid ? .white : .grayXl,
                             height: 40.0,
                             fontSize: valid ? 14.0 : 12.5,
                             font: valid ? .gmMedium : .gmlight)
            }
            .disabled(!viewLogic.subjectFieldText.isEmpty)
         }
      }
   }
   private func createSubjectView() -> some View {
      return FoldableGroupBox(title: AppTexts.WriteSayu.SUBJECT_TITLE.rawValue) {
         return VStack(alignment: .leading) {
            if !viewLogic.lastSayuSubject.isEmpty {
               VStack(alignment: .leading) {
                  Text(AppTexts.WriteSayu.SUBJECT_LAST_TITLE.rawValue)
                     .byCustomFont(.gmMedium, size: 13.0)
                     .foregroundStyle(.grayLg)
                  Spacer.height(8.0)
                  Text(viewLogic.lastSayuSubject)
                     .byCustomFont(.gmlight, size: 12.0)
                     .foregroundStyle(.grayLg)
               }
               .frame(maxWidth: .infinity, alignment: .topLeading)
               .padding(.all, 4.0)
               
               Spacer.height(20.0)
            }
            
            Text(AppTexts.WriteSayu.SYSTEMSUBJECT_RECOMMEND.rawValue)
               .byCustomFont(.gmMedium, size: 13.0)
               .foregroundStyle(.grayLg)
               .padding(.leading, 4.0)
            Spacer.height(12.0)
            
            createSystemSubjectSelection(viewLogic.systemSubjectItems)
            Spacer.height(20.0)
            
            Text(AppTexts.WriteSayu.SUBJECT_CREATE_NOTI.rawValue)
               .byCustomFont(.gmMedium, size: 13.0)
               .foregroundStyle(.grayLg)
               .padding(.leading, 4.0)
            Spacer.height(8.0)
            
            RoundedTextField(fieldText: $viewLogic.subjectFieldText,
                             placeholder: AppTexts.WriteSayu.SUBJECT_CREATE_PLACEHOLDER.rawValue,
                             font: .gmMedium,
                             fontSize: 15.0,
                             tint: .grayXl,
                             background: .grayXs,
                             foregroud: .grayXl,
                             height: 40.0)
            .disabled(viewLogic.selectedSystemSubject != nil)
            .focused($subjectFieldFocus)
            .onChange(of: viewLogic.subjectFieldText) { text in
               if viewLogic.isSubjectFieldOnSubmitTapped {
                  if !text.isEmpty {
                     viewLogic.isSubjectFieldOnSubmitTapped = false
                  } else {
                     viewLogic.isSubjectFieldOnSubmitTapped = true
                  }
               }
            }
            .onSubmit {
               viewLogic.isSubjectFieldOnSubmitTapped = true
            }
            
            
         }
         .frame(maxWidth: .infinity)
      } toggleHandler: { isNotOpen in
         if isNotOpen {
            subjectFieldFocus = false
            return false
         } else {
            if viewLogic.selectedSystemSubject == nil {
               if viewLogic.isSubjectFieldOnSubmitTapped {
                  subjectFieldFocus = false
               } else {
                  subjectFieldFocus = true
               }
            }
            return true
         }
      }
      .onTapGesture {
         subjectFieldFocus = false
      }
   }
}

extension WriteSayu {
   private func createSubView() -> some View {
      let subItems = viewLogic.subItems
      return FoldableGroupBox(
         title: AppTexts.WriteSayu.SUB_TITLE.rawValue + " (\(subItems.count)개)"
      ) {
         VStack {
            asRoundedRect(
               title: AppTexts.WriteSayu.SUB_NOTI.rawValue,
               radius: 16.0,
               background: .graySm,
               foreground: .baseBlack,
               height: 32.0,
               fontSize: 12.0,
               font: .gmlight)
            Spacer.height(16.0)
            
            if !subItems.isEmpty {
               ForEach(viewLogic.subItems.indices, id: \.self) { index in
                  createSubItem($viewLogic.subItems[index], index: index)
               }
            }
            
            if subItems.count < 6 {
               Spacer.height(12.0)
               Button {
                  withAnimation(.easeInOut) {
                     viewLogic.addSubItem()
                  }
               } label: {
                  asRoundedRect(
                     title: AppTexts.WriteSayu.SUB_ADD_BUTTON.rawValue,
                     radius: 8.0,
                     background: .graySm,
                     foreground: .grayXl,
                     height: 48.0,
                     fontSize: 15.0,
                     font: .gmMedium)
               }
            }
         }
      } toggleHandler: { isNotOpen in
         if isNotOpen {
            if subFieldFocus == nil {
               return false
            } else {
               return true
            }
         } else {
            return true
         }
      }
      .onTapGesture {
         subFieldFocus = nil
      }
   }
   private func createSubItem(_ item: Binding<SubViewItem>, index: Int) -> some View {
      return HStack(alignment: .center, spacing: 8.0) {
         RoundedTextField(
            fieldText: item.sub,
            placeholder: AppTexts.WriteSayu.SUB_ADD_PLACEHOLDER.rawValue,
            font: .gmMedium,
            fontSize: 13.0,
            tint: .grayXl,
            background: .grayXs,
            foregroud: .grayXl,
            borderWidth: 0.5,
            height: 40.0)
         .focused($subFieldFocus, equals: WriteSayuViewLogic.SubFieldFocus.init(rawValue: index))
         .onSubmit {
            subFieldFocus = nil
         }
         
         Button {
            viewLogic.removeSubItem(index)
         } label: {
            Image(.trash)
               .resizable()
               .frame(width: 16.0, height: 16.0)
         }
         .disabled(subFieldFocus != nil)
      }
   }
}

extension WriteSayu {
   private func createSayuTypeView() -> some View {
      let selectedType = viewLogic.selectedSayuType
      return FoldableGroupBox(title: AppTexts.WriteSayu.SAYU_TYPE_TITLE.rawValue) {
         VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
               ForEach(viewLogic.sayuTypes, id: \.id) { type in
                  asRoundedRect(
                     title: type.title,
                     radius: 12.0,
                     background: selectedType == type.type ? .baseGreen : .grayMd,
                     foreground: selectedType == type.type ? .white : .grayXl,
                     height: 32.0,
                     fontSize: 13.0,
                     font: .gmMedium
                  )
                  .onTapGesture {
                     withAnimation(.bouncy) {
                        viewLogic.setSayuType(type.type)
                     }
                  }
               }
            }
         }
      } toggleHandler: { isNotOpen in
         return !isNotOpen
      }
      
   }
}

extension WriteSayu {
   private func createSayuTimer() -> some View {
      let selectedType = viewLogic.selectedTimerType
      return FoldableGroupBox(
         title: AppTexts.WriteSayu.SAYU_TIME_SETTING_TITLE.rawValue
      ) {
         VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
               ForEach(viewLogic.sayuTimerTypes, id: \.id) { type in
                  asRoundedRect(
                     title: type.title,
                     radius: 12.0,
                     background: selectedType == type.type ? .baseGreen : .grayMd,
                     foreground: selectedType == type.type ? .white : .grayXl,
                     height: 32.0,
                     fontSize: 13.0,
                     font: selectedType == type.type ? .gmBold : .gmMedium
                  )
                  .onTapGesture {
                     withAnimation(.bouncy) {
                        viewLogic.selectedTimerType = type.type
                        if viewLogic.selectedTimerType == .stopWatch {
                           viewLogic.resetTimer()
                        }
                     }
                  }
               }
            }
            
            if selectedType == .timer {
               Spacer.height(16.0)
               
               asRoundedRect(
                  title: AppTexts.WriteSayu.SAYU_TIME_SETTING_NOTI.rawValue,
                  radius: 16.0,
                  background: .graySm,
                  foreground: .baseBlack,
                  height: 32.0,
                  fontSize: 12.0,
                  font: .gmMedium)
               
               HStack {
                  Picker("시", selection: $viewLogic.sayuTime.hours) {
                     ForEach(0..<3) { Text("\($0) 시").foregroundStyle(.baseBlack) }
                  }
                  
                  Picker("분", selection: $viewLogic.sayuTime.minutes) {
                     ForEach(0..<60) { Text("\($0) 분").foregroundStyle(.baseBlack) }
                  }
                  
                  Picker("초", selection: $viewLogic.sayuTime.seconds) {
                     ForEach(0..<60) { Text("\($0) 초").foregroundStyle(.baseBlack) }
                  }
               }
               .labelStyle(.titleOnly)
               .pickerStyle(.inline)
               .foregroundStyle(.baseBlack)
               .frame(maxHeight: 80)
            }
         }
      } toggleHandler: { isNotOpen in
         return !isNotOpen
      }
      
   }
}

extension WriteSayu {
   private func createSayuSmartList() -> some View {
      FoldableGroupBox(
         title: AppTexts.WriteSayu.SMARTLIST_TITLE.rawValue
      ) {
         VStack {
            asRoundedRect(
               title: AppTexts.WriteSayu.SMARTLIST_NOTI.rawValue,
               radius: 16.0,
               background: .graySm,
               foreground: .baseBlack,
               height: 32.0,
               fontSize: 12.0,
               font: .gmMedium)
            Spacer.height(20.0)
            
            SmartListCreator(smartListIcon: $viewLogic.smartListIcon,
                             smartLists: $viewLogic.smartList)
            Spacer.height(20.0)
            
            if !viewLogic.lastSayuSmartList.isEmpty {
               VStack(alignment: .leading) {
                  Text(AppTexts.WriteSayu.SMARTLIST_LAST_TITLE.rawValue)
                     .byCustomFont(.gmMedium, size: 13.0)
                     .foregroundStyle(.grayLg)
                  Spacer.height(8.0)
                  ScrollView(.horizontal) {
                     HStack(alignment: .center) {
                        ForEach(viewLogic.lastSayuSmartList, id: \.self) { list in
                           Text(list)
                              .byCustomFont(.gmlight, size: 12.0)
                              .foregroundStyle(.baseBlack)
                              .padding(.horizontal, 8.0)
                              .padding(.vertical, 6.0)
                              .background(Capsule()
                                 .fill(.white)
                              )
                        }
                     }
                  }
                  .frame(maxWidth: .infinity, alignment: .topLeading)
               }
               .frame(maxWidth: .infinity, alignment: .topLeading)
               .padding(.all, 4.0)
            }
         }
      } toggleHandler: { isNotOpen in
         return !isNotOpen
      }
   }
}

extension WriteSayu {
   func configure(view: NavigationConfig) -> NavigationConfig {
      view.navigationBackGesture(.drag)
   }
   
   private func dismissView() {
      let buttons: [BottomPopupButtonItem] = [
         .init(title: "취소", background: .graySm, foreground: .grayXl, action: dismiss),
         .init(title: "확인", background: .error, foreground: .white, action: dismissAndPopOut)
      ]
      BottomAlert(title: "작성을 중단하시나요?",
                  content: "확인을 터치하시면 지금까지 작성하신 내용이 저장되지 않습니다.",
                  buttons: buttons)
      .showAndStack()
   }
   
   private func dismissAndPopOut() {
      dismiss()
      popOutView()
   }
}

extension WriteSayu {
   private func popAlertCheckSubject() {
      BottomAlert(
         title: "사유 주제를 설정해주셨나요?",
         content: "추천 주제를 선택하거나 직접 사유할 주제를 만들어보세요 :)"
      )
      .showAndStack()
      .dismissAfter(2.5)
      viewLogic.setWriteValidNil()
   }
   
   private func popAlertCheckTimer() {
      BottomAlert(
         title: "사유 시간을 설정해주셨나요?",
         content: "타이머 방식으로 사유하시는 경우, 5분 이상 사유해보는 것은 어떨까요? :)"
      )
      .showAndStack()
      .dismissAfter(2.5)
      viewLogic.setWriteValidNil()
   }
   
   private func popAlertCheckCaution() {
      let cautions: [CautionItem] = [
         .init(content: "걷거나 달리는 중에는 주변을 잘 살펴주세요."),
         .init(content: "중요한 생각이 떠오르면 제자리에 멈춰서 작성해주세요."),
      ]
      BottomCautionCheckAlert(
         title: "꼭 확인해주세요.",
         content: "안전하고 건강한 사유를 위해 아래의 내용을 반드시 확인해주세요.",
         cautions: cautions,
         confirmButtonTitle: "사유 시작") {
            dismiss()
            viewLogic.writeSayu()
            
            if viewLogic.createdSayuId != nil {
               popOutView()
            }
         }
         .showAndStack()
   }
}
