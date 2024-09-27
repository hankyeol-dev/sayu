//
//  AppTexts.swift
//  sayu
//
//  Created by 강한결 on 9/25/24.
//

import Foundation

enum AppTexts {
   enum WriteSayu: String {
      case SUBJECT_TITLE = "사유 주제"
      case SYSTEMSUBJECT_RECOMMEND = "이런 주제는 어떤가요?"
      case SUBJECT_CREATE_NOTI = "주제를 직접 만들 수 있어요."
      case SUBJECT_CREATE_PLACEHOLDER = "주제 입력하기"
      case SUBJECT_LAST_TITLE = "최근에 이런 주제로 사유하셨어요."
      
      case SUB_TITLE = "함께 사유할 세부 내용"
      case SUB_NOTI = "사유하는 중에는 추가가 어려워요"
      case SUB_ADD_BUTTON = "추가"
      case SUB_ADD_PLACEHOLDER = "함께 사유할 내용을 입력해주세요."
      
      case SAYU_TYPE_TITLE = "사유 방식"
      
      case SAYU_TIME_SETTING_TITLE = "사유 시간 설정"
      case SAYU_TIME_SETTING_NOTI = "타이머 방식은 최대 3시간까지 설정할 수 있어요."
      
      case SMARTLIST_TITLE = "사유 목록을 추가해보세요"
      case SMARTLIST_LAST_TITLE = "최근에 이런 목록을 지정했어요."
      case SMARTLIST_NOTI = "최대 3개의 사유 목록을 지정할 수 있어요."
   }
}
