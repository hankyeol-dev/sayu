//
//  Repository.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation
import RealmSwift

struct Repository<O: Object> {
   private let db = try! Realm()
   
   enum RepositoryErrors: Error {
      case failForAdd
      case failForUpdate
      case recordNotFound
   }
   
   func getRecordById(_ id: ObjectId) -> O? {
      return db.object(ofType: O.self, forPrimaryKey: id)
   }
   
   func addSingleRecord(_ record: O, addHandler: @escaping (O) -> Void) throws {
      do {
         try db.write {
            db.add(record)
            addHandler(record)
         }
      } catch {
         throw RepositoryErrors.failForAdd
      }
   }
   
   func addMultiRecords(_ records: [O]) throws {
      do {
         try db.write {
            db.add(records)
         }
      } catch {
         throw RepositoryErrors.failForAdd
      }
   }
   
   func updateRecord(_ id: ObjectId, updateHandler: @escaping (O) -> Void) throws {
      
      let record = getRecordById(id)
      
      if let record {
         do {
            try db.write {
               updateHandler(record)
               db.add(record, update: .modified)
            }
         } catch {
            throw RepositoryErrors.failForUpdate
         }
      } else {
         throw RepositoryErrors.recordNotFound
      }
   }
}
