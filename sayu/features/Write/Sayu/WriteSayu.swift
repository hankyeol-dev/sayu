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
         .background(.white)
         .frame(maxWidth: .infinity)
         .padding(.horizontal, 16.0)
         
         Spacer()
         
         
         // MARK: 사유하기 버튼 영역
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
               font: .satoshiMedium)
         }
         .padding()
         .background(.graySm)
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
                             radius: 12.0,
                             background: valid ? .baseGreen : .grayMd,
                             foreground: valid ? .white : .grayXl,
                             height: 40.0,
                             fontSize: valid ? 13.0 : 12.0,
                             font: valid ? .kjcBold : .kjcRegular)
            }
            .disabled(!viewLogic.subjectFieldText.isEmpty)
         }
      }
   }
   private func createSubjectView() -> some View {
      return FoldableGroupBox(title: "사유 주제") {
         return VStack(alignment: .leading) {
            Text("이런 주제는 어때요?")
               .byCustomFont(.kjcRegular, size: 13.0)
            
            Spacer.height(12.0)
            
            createSystemSubjectSelection(viewLogic.systemSubjectItems)
            
            Spacer.height(20.0)
            
            Text("사유 주제를 직접 만들어보세요.")
               .byCustomFont(.kjcRegular, size: 13.0)
            
            Spacer.height(8.0)
            
            RoundedTextField(fieldText: $viewLogic.subjectFieldText,
                             placeholder: "주제를 입력해보세요.",
                             font: .kjcRegular,
                             fontSize: 13.0,
                             tint: .grayXl,
                             background: .grayXs,
                             foregroud: .grayXl,
                             height: 36.0)
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
   }
}

extension WriteSayu {
   private func createSubView() -> some View {
      let subItems = viewLogic.subItems
      return FoldableGroupBox(title: "함께 사유할 내용 (\(subItems.count)개)") {
         VStack {
            asRoundedRect(
               title: "사유하는 중에는 추가가 어려워요",
               radius: 16.0,
               background: .basebeige,
               foreground: .grayXl,
               height: 32.0,
               fontSize: 12.0,
               font: .kjcRegular)
            
            Spacer.height(16.0)
            
            if !subItems.isEmpty {
               ForEach(viewLogic.subItems.indices, id: \.self) { index in
                  createSubItem($viewLogic.subItems[index], index: index)
               }
            }
            
            if subItems.count < 6 {
               Button {
                  withAnimation(.easeInOut) {
                     viewLogic.addSubItem()
                  }
               } label: {
                  asRoundedRect(
                     title: "추가하기",
                     radius: 8.0,
                     background: .grayMd,
                     foreground: .grayXl,
                     height: 32.0,
                     fontSize: 15.0,
                     font: .satoshiMedium)
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
   }
   private func createSubItem(_ item: Binding<SubViewItem>, index: Int) -> some View {
      return HStack(alignment: .center, spacing: 8.0) {
         RoundedTextField(
            fieldText: item.sub,
            placeholder: "함께 사유할 내용을 입력해주세요.",
            font: .kjcRegular,
            fontSize: 13.0,
            tint: .grayXl,
            background: .grayXs,
            foregroud: .grayXl,
            borderWidth: 0.5,
            height: 36)
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
      return FoldableGroupBox(title: "사유 방식") {
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
                     font: selectedType == type.type ? .satoshiBold : .satoshiMedium
                  )
                  .onTapGesture {
                     withAnimation(.bouncy) {
                        viewLogic.selectedSayuType = type.type
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
      return FoldableGroupBox(title: "사유 시간 설정") {
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
                     font: selectedType == type.type ? .satoshiBold : .satoshiMedium
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
                  title: "타이머 방식은 최대 3시간까지 설정할 수 있어요.",
                  radius: 16.0,
                  background: .basebeige,
                  foreground: .grayXl,
                  height: 32.0,
                  fontSize: 12.0,
                  font: .kjcRegular)
               
               HStack {
                  Picker("시", selection: $viewLogic.sayuTime.hours) {
                     ForEach(0..<3) { Text("\($0) 시") }
                  }
                  
                  Picker("분", selection: $viewLogic.sayuTime.minutes) {
                     ForEach(0..<60) { Text("\($0) 분") }
                  }
                  
                  Picker("초", selection: $viewLogic.sayuTime.seconds) {
                     ForEach(0..<60) { Text("\($0) 초") }
                  }
               }
               .labelStyle(.titleOnly)
               .pickerStyle(.inline)
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
      return FoldableGroupBox(title: "사유 목록을 추가해보세요") {
         VStack {
            asRoundedRect(
               title: "최대 3개의 사유 목록을 지정할 수 있어요.",
               radius: 16.0,
               background: .basebeige,
               foreground: .grayXl,
               height: 32.0,
               fontSize: 12.0,
               font: .kjcRegular)
            SmartListCreator(smartListIcon: $viewLogic.smartListIcon,
                             smartLists: $viewLogic.smartList)
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
         content: "타이머 방식으로 사유하시는 경우,\n5분 이상 사유해보는 것은 어떨까요? :)"
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
         content: "걷거나 달리면서 사유하시는군요 👍\n안전하고 건강한 사유를 위해 아래의 내용을 반드시 확인해주세요.",
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
