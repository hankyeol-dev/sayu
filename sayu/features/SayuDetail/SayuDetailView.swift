//
//  SayuDetailView.swift
//  sayu
//
//  Created by 강한결 on 9/23/24.
//

import SwiftUI

import RealmSwift
import MijickNavigationView
import MijickPopupView

struct SayuDetailView: NavigatableView {
   private enum SubFieldFocus: Int {
      case first, second, third, fourth, fifth, sixth
   }
   
   @StateObject
   private var sayuDetailViewLogic: SayuDetailViewLogic = .init()
   
   @FocusState
   private var textEditorFocus: Bool
   
   @FocusState
   private var subEditorFocus: SubFieldFocus?
   
   private let sayuId: ObjectId
    
   init(sayuId: ObjectId) {
      self.sayuId = sayuId
   }
   
   var body: some View {
      VStack {
         AppMainNavbar {
            createLeftButton()
         } rightButton: {
            createRightButton()
         }
         
         if let sayu = sayuDetailViewLogic.sayu {
            VStack {
               ScrollView(showsIndicators: false) {
                  createDetailView(sayu)
               }
               .padding(.vertical, -8.0)
            }
         }
      }
      .background(.basebeige)
      .task {
         sayuDetailViewLogic.setSayu(sayuId)
         if sayuDetailViewLogic.sayu == nil {
            displayEmptyPopup()
         }
      }
      .onChange(of: sayuDetailViewLogic.isSavedError) { error in
         if error {
            displaySaveErrorPopup()
         }
      }
   }
}

extension SayuDetailView {
   private func createLeftButton() -> some View {
      Button {
         if sayuDetailViewLogic.isEditMode {
             displayNotSaveNoticePopup()
         } else {
            pop()
         }
      } label: {
         Image(.arrowBack)
            .resizable()
            .frame(width: 16.0, height: 8.0)
      }
   }
   
   private func createRightButton() -> some View {
      let isEditmode = sayuDetailViewLogic.isEditMode
      
      return Button {
         // 여기 사유 수정 로직 올거야.
         if isEditmode {
            textEditorFocus = false
            subEditorFocus = nil
            sayuDetailViewLogic.turnOffEditModeAndSave()
         } else {
            sayuDetailViewLogic.turnOnEditMode()
            textEditorFocus = true
         }
      } label: {
         Text(isEditmode ? "다시 저장" : "사유 내용 수정")
            .byCustomFont(.gmMedium, size: 15.0)
            .foregroundStyle(isEditmode ? .baseGreen : .grayXl)
      }
   }
   
   private func displayEmptyPopup() {
      CentreEmptySayuAlert()
         .showAndStack()
         .dismissAfter(1.5)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
         pop()
      }
   }
   
   private func displayNotSaveNoticePopup() {
      let buttons: [BottomPopupButtonItem] = [
         .init(title: "계속할게요", background: .baseGreen, foreground: .white, action: {
            dismiss()
         }),
         .init(title: "좋아요", background: .grayMd, foreground: .grayXl, action: {
            // not save and pop
            dismiss()
            pop()
         })
      ]
      BottomAlert(title: "이전 페이지로 돌아갈까요?",
                  content: "수정하던 사유 내용이 저장되지 않아요.\n그래도 괜찮으시다면 좋아요 버튼을 터치해주세요.",
                  buttons: buttons)
      .showAndStack()
   }
   
   private func displaySaveErrorPopup() {
      BottomAlert(title: "앗, 무언가 문제가 있어요.", content: "수정해주신 내용을 수정하는데 잠시 문제가 생겼어요.\n잠시 후 다시 시도해주세요.")
         .showAndStack()
         .dismissAfter(1.5)
   }
}

extension SayuDetailView {
   private func createDetailView(_ sayu: Think) -> some View {
      return VStack {
         createDetailSubject(sayuDetailViewLogic.sayuSubject)
         Spacer.height(16.0)
         
         createDetailInfo(sayu)
         Spacer.height(16.0)
         
         createDetailContents()
         Spacer.height(16.0)
         
         createDetailSubs()
         Spacer.height(16.0)
      }
      .padding(.horizontal, 16.0)
      .padding(.top, 12.0)
   }
   
   private func createDetailSubject(_ subject: String) -> some View {
      FoldableGroupBox(bg: .white, isOpenButton: false, title: "사유 주제") {
         HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Spacer()
            Text(subject)
               .byCustomFont(.kjcRegular, size: 18.0)
            Spacer()
         }
         .padding(.bottom, 8.0)
      } toggleHandler: { _ in return true }
   }
   
   private func createDetailInfo(_ sayu: Think) -> some View {
      return FoldableGroupBox(bg: .white, title: "사유 정보") {
         VStack(spacing: 20.0) {            
            if let date = sayu.date.formattedForView()?.formattedForView() {
               createDatailInfoContent("언제?",
                                       content: date)
            }
            
            createDatailInfoContent("어떻게?",
                                    content: ThinkType.byKoreanString(sayu.thinkType))
            createDatailInfoContent("얼마나?",
                                    content: sayu.timeTake.converTimeToCardViewString())
            
            if let steps = sayu.steps, steps != 0,
               let distance = sayu.distance, distance != 0.0 {
               createDatailInfoContent("사유 걸음 수",
                                       content: "\(steps.formatted()) 보")
               createDatailInfoContent("사유한 거리",
                                       content: "\(distance) km")
            }
            
            if !sayu.smartList.isEmpty {
               VStack(alignment: .leading) {
                  Text("사유 목록")
                     .byCustomFont(.gmlight, size: 13.0)
                     .foregroundStyle(.grayLg)
                     .lineSpacing(8.0)
                  Spacer.height(12.0)
                  WrappedChip(chips: sayu.smartList.map { $0.title }) { _ in }
               }
               .frame(maxWidth: .infinity, alignment: .topLeading)
               .padding(.horizontal, 8.0)
            }
         }
      } toggleHandler: { isNotOpen in
         !isNotOpen
      }
   }
      
   private func createDatailInfoContent(_ title: String, content: String) -> some View {
      return HStack(alignment: .center) {
         Text(title)
            .byCustomFont(.gmlight, size: 13.0)
            .foregroundStyle(.grayLg)
            .lineSpacing(8.0)
         Spacer()
         Text(content)
            .byCustomFont(.gmMedium, size: 15.0)
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.horizontal, 8.0)
   }
   
   private func createDetailContents() -> some View {
      return FoldableGroupBox(bg: .white, title: "사유 내용") {
         VStack {
            if sayuDetailViewLogic.isEditMode {
               TextEditor(text: $sayuDetailViewLogic.sayuContents)
                  .font(.byCustomFont(.kjcRegular, size: 15.0))
                  .lineSpacing(6.0)
                  .transparentScrolling()
                  .tint(.grayXl)
                  .foregroundStyle(.grayXl)
                  .background(.clear)
                  .focused($textEditorFocus)
                  .frame(maxWidth: .infinity)
                  .frame(minHeight: 200.0, maxHeight: 200.0)
            } else {
               Text(sayuDetailViewLogic.sayuContents)
                  .byCustomFont(.kjcRegular, size: 15.0)
                  .lineSpacing(6.0)
                  .padding(.horizontal, 8.0)
            }
         }
      } toggleHandler: { open in
         if open {
            if sayuDetailViewLogic.isEditMode {
               if textEditorFocus {
                  return true
               }
            }
         } else {
            if sayuDetailViewLogic.isEditMode && !textEditorFocus {
               return true
            }
         }
         return !open
      }
      .onTapGesture {
         textEditorFocus = false
      }
   }
   
   private func createDetailSubs() -> some View {
      
      return FoldableGroupBox(bg: .white, title: "사유 세부 내용") {
         VStack(alignment: .leading, spacing: 20.0) {
            ForEach(sayuDetailViewLogic.sayuSubs.indices, id: \.self) { index in
               VStack(alignment: .leading, spacing: 8.0) {
                  Text(sayuDetailViewLogic.sayuSubs[index].sub)
                     .byCustomFont(.gmlight, size: 13.0)
                     .foregroundStyle(.grayLg)
                  if sayuDetailViewLogic.isEditMode {
                     TextEditor(text: $sayuDetailViewLogic.sayuSubs[index].content)
                        .font(.byCustomFont(.kjcRegular, size: 15.0))
                        .transparentScrolling()
                        .background(.clear)
                        .tint(.grayXl)
                        .foregroundStyle(.grayXl)
                        .frame(maxHeight: 100.0)
                        .focused($subEditorFocus, equals: .init(rawValue: index))
                  } else {
                     Text(sayuDetailViewLogic.sayuSubs[index].content)
                        .byCustomFont(.kjcRegular, size: 16.0)
                        .foregroundStyle(.grayXl)
                  }
               }
               .frame(maxWidth: .infinity, alignment: .topLeading)
            }
         }
         .padding(.horizontal, 8.0)
      } toggleHandler: { isNotOpen in
         !isNotOpen
      }
      .onTapGesture {
         subEditorFocus = nil
      }
   }
}
