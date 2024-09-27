//
//  MotionManager.swift
//  sayu
//
//  Created by 강한결 on 9/21/24.
//

import Foundation
import CoreMotion

final class MotionManager: ObservableObject {
   private let pedometer = CMPedometer()
   private let todayStart = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
   private let todayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
   
   enum MotionManagerError: Error {
      case authorizationDenied
      case unknownError
      case motionIsNotCaptured
   }
   
   func getTodaySteps(_ handler: @escaping (Int) -> Void)  {
      if checkAuth(), let todayStart, let todayEnd {
         pedometer.queryPedometerData(from: todayStart, to: todayEnd) { data, error in
            if let data {
               DispatchQueue.main.async {
                  handler(Int(truncating: data.numberOfSteps))
               }
            }
         }
      }
   }
}

// MARK: - check CoreMotion Authorization
extension MotionManager {
   func getAuth() {
      pedometer.queryPedometerData(from: .now, to: .now) { _, _ in
         
      }
   }
   
   func checkAuth() -> Bool {
      if CMMotionManager().isDeviceMotionAvailable && (CMPedometer.authorizationStatus() == .authorized
                                                       || CMPedometer.authorizationStatus() == .restricted) {
         return true
      }
      return false
   }
}

// MARK: - fetch Motion Data
extension MotionManager {
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
      getHandler: @escaping(Int, Double, Double) -> Void,
      errorHandler: @escaping () -> Void
   ) throws {
      if !checkAuth() {
         throw MotionManagerError.authorizationDenied
      } else {
         pedometer.queryPedometerData(from: start, to: end) { pedometerData, error in
            
            guard error == nil else {
               return
            }
            
            if let pedometerData {
               let steps = pedometerData.numberOfSteps
               if let distance = pedometerData.distance,
                  let avgPace = pedometerData.averageActivePace {
                  DispatchQueue.main.async { [weak self] in
                     guard let self else { return }
                     getHandler(steps.intValue,
                                convertDistancePerKM(distance.doubleValue),
                                avgPace.doubleValue)
                  }
               } else {
                  DispatchQueue.main.async {
                     errorHandler()                     
                  }
               }
            }
         }
      }
   }
   
   private func convertDistancePerKM(_ distance: Double) -> Double {
      let convertedMeter = round(distance * 10.0) / 10.0
      let convertedKM = convertedMeter / 1000.0
      return (round(convertedKM * 100.0) / 100.0)
   }
}
