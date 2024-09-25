//
//  BarChartView.swift
//  sayu
//
//  Created by 강한결 on 9/25/24.
//

import SwiftUI

struct BarChartView: View {
   var body: some View {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
   }
}

struct Bar: Identifiable {
   let id = UUID()
   var name: String
   var day: String
   var value: Double
   var color: Color
   
   static var sampleBars: [Bar] {
      var tempBars = [Bar]()
      var color: Color = .green
      let days = ["M","T","W","T","F","S","S"]
      
      for i in 1...7 {
         let rand = Double.random(in: 20...200.0)
         
         if rand > 150 {
            color = .red
         } else if rand > 75 {
            color = .yellow
         } else {
            color = .green
         }
         
         let bar = Bar(name: "\(i)",day: days[i-1], value: rand, color: color)
         tempBars.append(bar)
      }
      return tempBars
   }
}

struct BarChart: View {
   @State private var bars = Bar.sampleBars
   @State private var selectedID: UUID = UUID()
   
   var body: some View {
      VStack {
         HStack(alignment: .bottom) {
            withAnimation(.easeIn) {
               ForEach(bars) { bar in
                  VStack {
                     ZStack {
                        Rectangle()
                           .foregroundColor(bar.color)
                           .frame(width: 35, height: bar.value, alignment: .bottom)
                        
                           .opacity(selectedID == bar.id ? 0.5 : 1.0)
                           .cornerRadius(6)
                           .onTapGesture {
                              self.selectedID = bar.id
                           }
                        Text("\(Int(bar.value))")
                           .foregroundColor(.white)
                     }
                     Text(bar.day)
                  }
                  
               }
            }
         }
         .frame(height:240, alignment: .bottom)
         .padding(20)
         .cornerRadius(6)
      }
   }
}
