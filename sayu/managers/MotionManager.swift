//
//  MotionManager.swift
//  sayu
//
//  Created by 강한결 on 9/21/24.
//

import Foundation
import CoreMotion

struct MotionManager {
   private let pedometer = CMPedometer()
   
   enum MotionManagerError: Error {
      case authorizationDenied
      case unknownError
   }
      
   func getAuth() {
      pedometer.queryPedometerData(from: .now, to: .now) { _, _ in
         
      }
   }
   
   func checkAuth() -> Bool {
      if CMPedometer.authorizationStatus() == .denied
            || CMPedometer.authorizationStatus() == .notDetermined {
         return false
      }
      return true
   }
   
   func startUpdate(
      _ start: Date,
      startHandler: @escaping (NSNumber, NSNumber, NSNumber) -> Void) throws {
      
      if !checkAuth() {
         throw MotionManagerError.authorizationDenied
      } else {
         pedometer.startUpdates(from: start) { pedometerData, error in
            guard error == nil else { return }
            
            if let pedometerData {
               let steps = pedometerData.numberOfSteps
               if let distance = pedometerData.distance,
                  let avgPace = pedometerData.averageActivePace {
                  startHandler(steps, distance, avgPace)
               }
            }
         }
      }
   }
   
   func stopUpdate() throws {
      if !checkAuth() {
         throw MotionManagerError.authorizationDenied
      } else {
         pedometer.stopUpdates()         
      }
   }
   
   func getMotionData(
      start: Date,
      end: Date,
      getHandler: @escaping(NSNumber, NSNumber, NSNumber) -> Void
   ) throws {
      if !checkAuth() {
         throw MotionManagerError.authorizationDenied
      } else {
         pedometer.queryPedometerData(from: start, to: end) { pedometerData, error in
            guard error == nil else { return }
            
            if let pedometerData {
               let steps = pedometerData.numberOfSteps
               if let distance = pedometerData.distance,
                  let avgPace = pedometerData.averageActivePace {
                  getHandler(steps, distance, avgPace)
               }
            }
         }
      }
   }
}
