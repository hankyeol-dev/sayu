//
//  FlexableTextView.swift
//  sayu
//
//  Created by 강한결 on 9/21/24.
//

import SwiftUI

struct FlexableTextView: UIViewRepresentable {
   
   @Binding var text: String
   @Binding var height: CGFloat
   var placeholder: String = ""
   
   var maxHeight: CGFloat = 0
   var maxTextCount: Int = 100
   
   /// Font, Color
   var textFont: Font.CustomFont = .kjcRegular
   var textColor: UIColor = .baseBlack
   var placeholderColor: UIColor = .baseBlack.withAlphaComponent(0.5)
   
   /// UI
   var radius: CGFloat = 12.0
   var borderWidth: CGFloat = 1.0
   var borderColor: CGColor = UIColor.grayMd.cgColor
   var inset: UIEdgeInsets = .init(top: 8.0, left: 12.0, bottom: 0.0, right: 12.0)
   
   /// actionable
   var isScrollEnable: Bool = true
   var isEditable: Bool = true
   var isUserInteractionEnable: Bool = true
   
   
   func makeUIView(context: Context) -> UITextView {
      let view = UITextView()
      
      view.layer.cornerRadius = radius
      view.layer.masksToBounds = true
      view.layer.borderWidth = borderWidth
      view.layer.borderColor = borderColor
      
      view.text = placeholder
      view.textColor = placeholderColor
      view.font = .init(name: textFont.rawValue, size: 15.0)
      view.isScrollEnabled = isScrollEnable
      view.isEditable = isEditable
      view.isUserInteractionEnabled = isUserInteractionEnable
      view.textContainerInset = inset
      view.delegate = context.coordinator
      
      return view
   }
   
   func updateUIView(_ uiView: UIViewType, context: Context) {
      updateHeight(uiView)
   }
   
   func makeCoordinator() -> CustomTextViewCoordinator {
      return .init(self)
   }
   
   private func updateHeight(_ view: UITextView) {
      let size = view.sizeThatFits(.init(width: view.frame.width, height: .infinity))
      DispatchQueue.main.async {
         if size.height <= maxHeight {
            height = size.height
         }
      }
   }
   
}

extension FlexableTextView {
   class CustomTextViewCoordinator: NSObject, UITextViewDelegate {
      var instance: FlexableTextView

      init(_ instance: FlexableTextView) {
         self.instance = instance
      }
      
      func textViewDidChange(_ textView: UITextView) {
         instance.text = textView.text
         
         if textView.text.isEmpty {
            textView.textColor = instance.placeholderColor
         } else {
            textView.textColor = instance.textColor
         }
         
         if textView.text.count > instance.maxTextCount {
            textView.text.removeLast()
         }
         
         instance.updateHeight(textView)
      }
      
      func textViewDidBeginEditing(_ textView: UITextView) {
         if textView.text == instance.placeholder {
            textView.text = ""
         }
      }
      
      func textViewDidEndEditing(_ textView: UITextView) {
         if textView.text.isEmpty {
            textView.text = instance.placeholder
         }
      }
   }
}

