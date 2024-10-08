# 슬기로운 사유생활

## 프로젝트 소개

걷거나 달리면서 그날 하루의 생각거리를 저장하는 일상 속 사유 앱

- 참여자: 강한결 (1인 앱스토어 출시 프로젝트)
- 앱 다운로드: [링크](https://apps.apple.com/kr/app/%EC%8A%AC%EA%B8%B0%EB%A1%9C%EC%9A%B4-%EC%82%AC%EC%9C%A0%EC%83%9D%ED%99%9C/id6720723938) (iOS 전용)
- 기간: 2024.09.16 ~ 2024.09.30 (10.01 앱 출시)
- 최소 지원 버전: iOS 15.0+

<br />

## 구현 스택

> - SwiftUI, CoreMotion
> - RealmSwift
> - MVVM

구현 방식

- SwiftUI 기반으로 선언적인 뷰 코드를 작성하고, 각각의 프로퍼티래퍼를 통해 데이터 흐름을 관리했습니다.
- ObservableObject 프로토콜을 준수하는 ViewModel 객체에서 데이터 로직과 뷰 이벤트 로직을 처리하도록 코드를 작성하였습니다.
- CoreMotion 프레임워크 API를 활용해 걷기/달리기 모드의 모션 데이터를 활용하였습니다.
- Realm 라이브러리를 활용하여 유저 기기에 영구적으로 저장되는 데이터를 관리하였습니다.

<br />

## 앱 구현에서 고민한 것들

### RealmSwift 기반의 로컬 데이터베이스를 효율적으로 관리하기 위한 Repository 패턴 적용

- 프로젝트에서 활용되는 데이터는 총 6개의 Realm Object 테이블에서 관리되었습니다.
  - 1️⃣ 각각의 테이블을 필요할 때마다 인스턴스화 하여 접근하는 것은 불필요한 코드의 반복이 있을 것이라 판단했습니다.
    - 그런 이유로, 구조화된 틀을 만들고 그 안에서 동일한 방식으로 동작하는 메서드와 동일한 에러 케이스를 던질 수 있도록 **`Repository<Entity: Object>`** 구조체를 활용했습니다.
  - 2️⃣ Object 타입의 Realm 테이블 객체를 호출하는 시점에서 추론할 수 있도록 코드를 작성했습니다.
  - 3️⃣ 구조체 내부에서는 로컬 데이터베이스의 레코드들을 조회, 업데이트, 필터링, 삭제할 수 있는 메서드를 각각 정의하여 ViewModel이 동일한 방식으로 활용할 수 있게 했습니다.
    - 특히, 관계성이 있는 테이블간의 데이터 처리가 필요한 경우를 핸들링하기 위해 클로저를 인자로 받는 메서드를 정의해 쓰기 및 업데이트 작업시에 각 ViewModel이 필요로 하는 로직을 실행할 수 있도록 했습니다.
      ```swift
         func addSingleRecord(_ record: Entity, addHandler: @escaping (Entity) -> Void) throws {
            do {
               try db.write {
                  db.add(record)
                  addHandler(record)
               }
            } catch {
               throw RepositoryErrors.failForAdd
            }
         }
      ```
- Realm 라이브러리 자체에서 SwiftUI에 대응하기 위해 `ObjectKeyIdentifiable 프로토콜` 이나 `@ObservedResults`와 같은 프로퍼티 래퍼를 갖추고 있습니다.
  - 다만, sayu 프로젝트에서는 관계가 얽혀있는 다른 테이블의 데이터를 함께 참조하거나, 함께 저장하는 경우가 많았습니다.
  - 또한, ViewModel에서 Realm 데이터베이스를 다루기에는 Repository 패턴으로 코드에 접근하는 것이 잘 맞다고 판단했습니다.

<br />

### CoreMotion 프레임워크를 통한 실시간 모션 데이터 확보

- 프로젝트 컨셉에 따라 걷거나, 달리는 활동에 대한 모션 측정 필요했습니다.
  - 1️⃣ Healkit, CoreMotion 이라는 두 가지 프레임워크 선택지가 있었습니다.
    - 앱의 주요 컨셉이 '운동을 기록'하는 것이 아닌 '운동을 하면서 내 생각을 정리' 하는 것이었기 때문에 CoreMotion을 통한 걸음 수, 이동 거리, 평균 페이스 정도의 데이터를 수집하는 것으로 방향을 잡았습니다.
  - 2️⃣ CoreMotion 프레임워크가 제공하는 API를 활용하는 서비스 객체를 만들고, 모션 데이터가 앱 전반에 걸쳐 활용되어야 했기에 ObservableObject 프로토콜을 채택해 @EnvironObject로 계층에 상관없이 접근될 수 있게 처리했습니다.
  - 3️⃣ CoreMotion에서 제공하는 pedometer 객체(만보기 객체)를 활용해 유저의 실시간 모션 데이터, 특정 기간의 모션 데이터를 수집하는 로직을 구현했습니다.
    - 사유를 시작하는 시점에 모션 업데이트를 시작하고, 사유 기록 내용이 저장되는 시점에 업데이트를 종료해 데이터를 로컬 데이터베이스에 정재해서 저장했습니다.
      ```swift
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
      ```
  - 4️⃣ CoreMotion의 API가 completionHandler와 같이 엔딩 클로져를 통해서만 데이터를 제공하는 점이 아쉬웠습니다.
    - `pedometer.stopUpdates()` 가 호출되기 전까지의 실행 환경을 유지하기 위해서는 클로저로 메모리를 차지하는 것이 필요했을 것이라고 판단했습니다.
    - 실시간 모션 데이터를 다른 객체 로직에서 접근해야 했기 때문에, 자연스럽게 클로저 안에서 클로저 구문이 돌아가도록 설정해야 했고, 이런 부분이 코드 가독성을 저하시켰던 것 같습니다.
    - AsyncStream과 같이 데이터를 쪼개서 활용하는 방법을 스스로 채택해보는 것도 좋지 않았을까 하는 생각을 하게 되었습니다.

<br />

### scenePhase 환경 변수를 활용한 백그라운드 사유 시간 계산

- 유저가 앱을 백그라운드로 전환하는 경우에도 사유하는 시간을 계산해야 했습니다.
  - 1️⃣ 우선, 앱이 백그라운드 또는 액티브한 상태인지 확인하기 위해서 `.scenePhase`라고 하는 환경변수를 @Envirionment 래퍼로 조회했습니다.
  - 2️⃣ onChange 모디파이어에서 해당 변수의 상태에 따른 분기를 처리해주었습니다.
    - 앱이 백그라운드로 넘어가, scenePhase 값이 `.background`가 되는 순간 타임스탬프로 시간을 저장했습니다.
    - 앱이 다시 포그라운드로 `.active` 한 상태가 되면 `Date().timeIntervalSince(이전에 저장한 타임스탬프 값)` 으로 백그라운드에서 앱이 머문 인터벌 시간 값을 계산해주었습니다.
    - 타이머 방식의 경우 유저가 최초에 설정한 시간 값에서 해당 인터벌을 차감했고, 스톱워치 방식은 반대로 더해주는 형태로 시간 데이터를 업데이트하여 뷰를 같이 업데이트 할 수 있었습니다.
    ```swift
      if phaseStatus == .active {
         let difference = Date().timeIntervalSince(viewLogic.isActiveLastTimeStamp)
         if (viewLogic.sayuSettingTime - Int(difference)) <= 0 {
            viewLogic.isPaused = true
            viewLogic.isStopped = true
            viewLogic.sayuSettingTime = 0
            viewLogic.sayuTimerProgress = 1.0
          } else {
            viewLogic.sayuSettingTime -= Int(difference)
          }
     }
    ```
- 3️⃣ 다소 아쉬운 점은, 앱이 suspend 된 상태까지는 scenePhase 환경 변수 하나만으로는 확인할 수 없었습니다.
  - 사유 내용을 저장하는 이벤트를 버튼 하나에만 고정시키고, 앱이 강제로 종료되는 상황에서는 사유 내용이 임시 저장될 수 있도록 처리하여 suspend 상태를 대응할 수 있게 했습니다.

<br />

## 앱 구현 화면

| 1. 앱 온보딩                                                                                              | 2. 오늘의 사유 구성1                                                                                      | 3. 오늘의 사유 구성2                                                                                      | 4. 오늘의 사유하기                                                                                        |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/6bb2d864-059a-419e-921f-9dfd6bb0e3ae" /> | <img width="200" src="https://github.com/user-attachments/assets/c4af4629-7f13-4fa1-83a5-445cd68abd2a" /> | <img width="200" src="https://github.com/user-attachments/assets/5c39d8df-edd5-4584-9d04-e4d5fe9eafbf" /> | <img width="200" src="https://github.com/user-attachments/assets/8358e269-0e6f-4acf-bbb0-006d0ada9347" /> |

- 앱을 처음 설치한 경우, 앱 기본 사항을 파악할 수 있는 온보딩 페이지가 노출되도록 했습니다.
  - 걷기/달리기 데이터 수집을 위한 모션 데이터에 대한 안내를 넣어 자연스러운 권한 확보로 이어질 수 있도록 설계했습니다.
- 오늘의 사유하기에 필요한 주제, 세부 주제, 사유 모드 설정, 사유 시간 설정, 스마트 목록 설정을 할 수 있습니다.
- 설정한 사유 방식(앉아서, 걸으면서, 달리면서)과 사유 시간 측정 방식(타이머/스톱워치)에 따라 오늘의 사유를 진행할 수 있습니다.

<br />

| 5. 캘린더 뷰                                                                                              | 6. 타임라인 뷰                                                                                            | 7. 사유 포인트 뷰                                                                                         | 8. 사유 기록 데이터                                                                                       |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/65f90abe-2b57-47f2-b598-ad4a701cb528" /> | <img width="200" src="https://github.com/user-attachments/assets/b654d465-cd55-4c91-9407-bcd1082a2e17" /> | <img width="200" src="https://github.com/user-attachments/assets/6ad7af90-606f-4790-a21c-94093d313b57" /> | <img width="200" src="https://github.com/user-attachments/assets/76cfc818-ec46-43e6-ac2a-57b735be1a3c" /> |

- 요일별로 작성한 사유 기록을 캘린더, 타임라인뷰로 각각 조회할 수 있도록 구현했습니다.
  - 각각의 사유 기록을 터치하면 상세 내용을 확인할 수 있습니다.
  - 획득한 사유 포인트로 당일에 저장하지 못하고 넘어간 사유 기록을 다시 시작할 수 있습니다.
- 사유 작성, 앱 접속, 걸음 수 등의 조건으로 앱 내부에서 활용 가능한 사유 포인트를 수집할 수 있습니다.
- 기록된 사유 관련 데이터를 정리해서 볼 수 있습니다.

<br />

## 프로젝트 회고

- tbd
