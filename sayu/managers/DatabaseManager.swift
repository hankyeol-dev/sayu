//
//  DatabaseManager.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation
import RealmSwift

final class DatabaseManager: ObservableObject {
   static let manager: DatabaseManager = .init()
   
   private var config: Realm.Configuration
   private let db: Realm
   
   private init() {
      config = Realm.Configuration()
      config.schemaVersion = 0
      
      db = try! Realm(configuration: config)
      setInitialValue()
   }
   
   func getDBConfig() -> Realm.Configuration { return config }
   func getDBURL() { if let url = config.fileURL { print(url) } }
   
   // MARK: - private function
   private func setInitialValue() {
      let subjects = db.objects(Subject.self)
      if subjects.isEmpty {
         do {
            try db.write {
               SystemSubjects.allCases.forEach { subject in
                  db.add(Subject(title: subject.byKoreanSubject, isSystemSubject: true))
               }
            }
         } catch {
            // TODO: - 여기 에러를 어떻게 핸들링 할 지 고민해보자.
            dump(error)
         }
      }
   }
}
