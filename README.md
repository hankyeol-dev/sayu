# 슬기로운 사유생활

**목차**

- [프로젝트 소개](#-프로젝트-소개)
- [프로젝트 아키텍처 및 스택](#-프로젝트-아키텍처-및-구현-스택)
- [프로젝트에서 고민한 것](#-프로젝트에서-고민한-것)
- [프로젝트 구현 화면 및 기능](#-프로젝트-구현-화면)

<br />

## 🚶 프로젝트 소개

걷거나 달리면서 그날의 고민거리를 정리하여 하나의 생각으로 만드는 생각 기록 앱

- 개발 인원 : 강한결 (1인 프로젝트)
- 기간
  - 2024.09.16 ~ 09.30 (10/1 앱스토어 출시)
- 최소 지원 버전 : iOS 15.0
- 앱 링크 : [다운로드 링크](https://apps.apple.com/kr/app/%EC%8A%AC%EA%B8%B0%EB%A1%9C%EC%9A%B4-%EC%82%AC%EC%9C%A0%EC%83%9D%ED%99%9C/id6720723938)
- 주요 기능
  - 걷거나 달리거나 조용히 앉아서 매일매일의 생각을 정리하고 기록할 수 있습니다.
    - 걷고 달리면서 사유하면 움직인 데이터를 함께 저장합니다.
  - 저장한 생각 기록은, 앱을 사용하는 동안 모아볼 수 있습니다.
    - 월 별, 타임라인 별로 직접 작성한 사유 데이터를 확인해보세요.
  - 저장된 생각 데이터를 막대 바 차트와 수치화 된 지표로 확인할 수 있습니다.

<br />

## 🚶 프로젝트 아키텍처 및 구현 스택

**SwiftUI 기반의 MVVM 아키텍처**

- SwiftUI 기반으로 선언적인 View를 구성하였습니다.
  - SwiftUI의 프로퍼티래퍼를 통해 ViewModel과의 상호작용 및 View 계층간의 데이터 흐름을 관리했습니다.
- ObservableObject를 채택한 ViewModel에서 데이터 상태와 비즈니스 로직을 관리했습니다.

**CoreMotion 프레임워크**

- `CMPedometer` (만보기) API를 활용하여 유저의 실시간 걷기, 달리기에 대한 모션 데이터를 수집 및 가공했습니다.

**RealmSwift**

- 유저의 생각 기록, 모션 데이터, 포인트 내역을 앱 사용기간 동안 영구적으로 저장하고 활용하기 위한 로컬 데이터베이스 구성 목적으로 활용했습니다.
- 데이터 유형에 맞는 테이블을 구성하고, 테이블 타입을 생성 시점에 추론할 수 있는 Repository 패턴을 적용했습니다.

<br />

## 🚶 프로젝트에서 고민한 것

### 1. RealmSwift 기반의 로컬 데이터베이스를 효율적으로 관리하기 위한 Repository 패턴 적용

> [관련 코드](https://github.com/hankyeol-dev/sayu/blob/main/sayu/models/entity/Repository.swift)

1️⃣ 고민한 부분

- 유저가 기록한 생각과 포인트 내역을 앱이 사용되는 동안 영구적으로 저장하고 조회할 수 있어야 했습니다.
- View에서 필요로 하는 데이터를 직접 접근하는 것이 아닌, ViewModel에서 조회/저장/가공하여 전달할 수 있어야 했습니다. 데이터가 활용될 때마다 데이터베이스 인스턴스를 생성하거나, 접근 코드가 반복적으로 작성되지 않는 효율적인 방식이 필요하다고 판단했습니다.

2️⃣ 고민을 풀어낸 방식

- 생각 기록 및 포인트 내역 저장을 위해 6개의 테이블(Object)을 구성하고, 테이블간 관계를 구성했습니다.
- 테이블 인스턴스를 동일한 방식으로 접근하기 위해, `Repository<Entity: RealmObject>` 구조체를 구현했습니다.

  - ViewModel에 Repository 객체를 생성하는 시점에 테이블의 타입을 추론할 수 있도록 RealmObject 프로토콜로 제약을 건 제네릭을 설정했습니다.

    ```swift
      struct Repository<Entity: RealmObject> {
         private var db = try! Realm()

         enum RepositoryErrors: Error {
            case failForAdd
            case failForUpdate
            case recordNotFound
         }
         ...
      }
    ```

  - Repository 구조체 내부에서는 추론된 테이블 타입에 맞게 레코드를 생성/조회(필터링)/수정/삭제하는 메서드를 구성하여 테이블 타입에 상관없이 동일하게 동작하도록 구현했습니다.
    - 관계가 구축된 테이블간의 데이터 처리를 위해, 탈출 클로저를 인자로 받는 메서드를 함께 구현했습니다.
      ```swift
       func addSingleRecord(_ record: Entity, addRecordHandler: @escaping (Entity) -> Void) {
           do {
              try db.write {
                 db.add(record)
                 addRecordHanlder(record)
              }
           } catch {
              throw RepositoryErrors.failForAdd
           }
        }
      ```
  - 데이터베이스 접근시, 발생할 수 있는 에러케이스 역시 Repository 구조체 내부에서 일관되게 설정했습니다.

- ViewModel에서는 Repository의 멤버나 내부 로직 구현부에 상관없이, 필요한 테이블 타입에 맞춰 Repository 객체를 생성하고 내부 기능을 활용해 데이터를 활용하는 로직을 구성할 수 있었습니다.

3️⃣ 아쉬운 점과 개선 방향성

- Realm 라이브러리는 SwiftUI에 대응하는 `ObjectKeyIdentifiable 프로토콜`, `@ObservedResults` 프로퍼티 래퍼를 갖추고 있습니다.
  - SwiftUI 기반으로 프로젝트를 진행했고, 데이터에 대한 별다른 이벤트가 없는 View에서는 ObservedResults로 데이터베이스를 직접 활용할 수도 있었다고 생각합니다. 다만, 모든 상위 View에서 ViewModel을 참조하고 있고, ViewModel에서 데이터 흐름을 관장하는 프로젝트 구조상 Repository 객체를 활용하는 것이 효율적이라고 판단했습니다.

<br />

### 2. CoreMotion 프레임워크를 통한 실시간 모션 데이터 활용

1️⃣ 고민한 부분

- 기획단계부터, 유저가 걷거나 달리는 중에 앱을 활용해 생각하고 기록하는 경험을 제공하고 싶었습니다.
  - 걷거나 달리는 모드로 생각을 기록하는 경우, 걸음 수/거리/페이스와 같은 모션 데이터를 함께 활용할 수 있는 방향으로 기획을 확장시켰습니다. 기획 사항에 맞춰, 앱을 사용하는 동안의 모션 데이터를 수집할 수 있어야 했습니다.

2️⃣ 고민을 풀어낸 방식

- 아이폰을 통해 유저의 모션을 감지하기 위해 HealthKit, CoreMotion 의 두 가지 프레임워크를 각각 활용하는 선택지가 있었습니다.
  - HealthKit 프레임워크의 HKWorkout, HKWorkoutSession과 같은 API는 유저의 운동에 초점을 맞춰 모션 데이터를 수집하고 건강 데이터로 기록할 수 있었습니다.
  - CoreMotion 프레임워크는 유저의 움직임에 따라 아이폰의 자이로스코프 센서가 감지한 모션 정보를 API 형태로 제공하고 있었습니다.
  - 앱 컨셉이 '운동을 기록하면서 생각을 정리한다'가 아닌 **'걷거나 달리면서도 내 생각을 정리할 수 있다'** 에 있었기 때문에 CoreMotion에서 제공하는 만보기 API (CMPedometer)를 선택했습니다.
- 생각을 기록하는 View, 기록된 데이터를 차트/수치화하여 보여주는 View, 걸음 수에 따라 포인트를 지급하는 View에서 각각 모션 데이터를 활용했습니다.

  - CoreMotion API를 범용적으로 활용하고 앱 전반에 걸쳐 활용될 수 있도록 @ObservableObject 프로토콜을 채택한 MotionManager를 구성했습니다. View에서는 @EnvironObject를 활용하여 View 계층에 상관없이 모션 데이터가 필요한 View에 MotionManager를 주입해 사용했습니다.
  - MotionManager 내부에서는 CMPedometer 인스턴스의 API로 유저의 실시간 모션 데이터를 수집하는 로직을 구현했습니다. `startUpdate(from: Date)` API는 pedometer 인스턴스를 참조하고 `stopUpdates` API가 호출되기 전까지 pedometerData를 클로저 내부에서 제공해주었습니다. 클로저 구문에서는 필요한 데이터를 선택하여 활용할 수 있었습니다. (steps, distance, avgPage 속성 활용) 유저가 생각 기록을 마치고 `사유 저장` 버튼을 터치했을 때, 최종적으로 stopUpdate 메서드를 호출하여 필요한 모션 데이터를 저장할 수 있었습니다.

    ```swift
    func startMotionUpdate(_ start: Date, startHandler: @escaping(NSNumber, NSNumber, NSNumber) -> Void) throws {
      if !checkAuth() {
        throw MotionManagerError.authorizationDenied
      }

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

    func stopUpdate() throws {
      if !checkAuth() {
         throw MotionManagerError.authorizationDenied
      } else {
         pedometer.stopUpdates()
      }
    }
    ```

3️⃣ 아쉬운 점과 개선 방향성

- CoreMotion의 API가 completionHandler와 같이 클로져 컨텍스트를 통해서만 데이터에 접근할 수 있다는 점이 아쉬웠습니다.
  - `pedometer.stopUpdates()` API가 호출되기 전까지 동일한 pedometer 인스턴스를 참조하며 계속 모션 데이터를 탐지해야하기 때문에 클로저로 메모리를 차지하는 것이 필요했을 것이라 판단했습니다.
  - 모션 데이터를 다른 로직에서 사용하기 위해서는 자연스럽게 클로저 안에서 콜백 형태로 또 다른 클로저가 실행되어야 했습니다. 이런 점이 모션 데이터를 활용하는 코드의 가독성을 떨어뜨렸습니다.
  - AsyncStream과 같이 계속 수집되는 데이터를 쪼개서 활용하는 방법을 선택할 수 있을 것 같습니다.

<br />

### 3. scenePhase 환경 변수를 활용해 백그라운드 상태에서 생각 기록 시간 관리

1️⃣ 고민한 부분

- 유저가 타이머 형식으로 지정한 생각 정리 시간이나 스톱워치 형식으로 측정하기 시작한 생각 정리 시간을 앱 백그라운드 상태에서도 유지해야 했습니다.
  - 유저가 걷거나 달리는 모드를 지정하여 생각을 기록할 때, 앱을 백그라운드 상태로 전환시킬 수 있기 때문에, 백그라운드에서 액티브 상태로 전환될 때까지의 시간을 계산해야 했습니다.

2️⃣ 고민을 풀어낸 방식

- 시간 계산이 필요한 데일리 생각(사유) 기록 View에 앱 운영 상태를 파악할 수 있는 환경 변수 `\.scenePhase`를 선언했습니다.
- 유저가 데일리 생각(사유) 기록 View에 접근하여 설정한 시간이 초 단위로 계산됩니다. onChange 구문에서 scenePhase로 바라보고 있는 앱 운영 상태에 따른 ViewModel 로직을 분기처리 했습니다.

  - 앱 운영 상태가 `.active`인 경우, 유저가 생각을 기록하면서 계속 앱 화면을 띄워놓고 있는 상태이기 때문에 별다른 처리 없이 기존의 시간 계산 로직이 계속 처리됩니다.
  - 앱 운영 상태가 `.background`가 되어 해당 분기로 들어오는 순간 ViewModel에 TimeStamp를 찍어 시점을 기록했습니다. 이후, 다시 앱 화면이 `foreground`로 들어와 `.inActive` 상태가 되는 시점에 `Date.timeIntervalSince(TimeStamp)` 구문으로 background 상태였던 시간을 계산하였습니다.

    ```swift
    .onChange(of: operationStatus) { status in
      if status == .background {
         viewModel.backgroundTimestamp
      }

      if status == .active {
         let difference = viewModel.backgroundTimeInterval // Int Value

         if (viewModel.sayuSettingTime - difference) <= 0 {
            // 타이머 방식으로 지정한 시간을 모두 초과한 경우에만
            viewModel.isPaused = true
            ...
         } else {
            // 타이머 방식으로 지정한 시간이 남은 경우, 설정한 시간에서 차감
            viewModel.sayuSettingTime -= difference

            // 스톱워치 방식일 경우, 이전까지 계산된 시간에 추가
            viewModel.sayuTime += difference
         }
      }
    }
    ```

    - 데일리 생각 기록 기능에서 유저는 타이머, 스톱워치 방식으로 각각 시간을 측정할 수 있습니다. 타이머 방식의 경우는 유저가 시간을 직접 지정하기 때문에, 백그라운드 상태에서 머문 시간만큼을 지정한 시간에서 차감해주었습니다. 스톱워치 방식은 0초부터 시작하여 유저가 생각 기록을 저장하기 직전까지를 계산하기 때문에, 백그라운드에서 머문 시간만큼을 더해주었습니다.

3️⃣ 아쉬운 점과 개선 방향성

- scenePhase 변수로 확인할 수 있는 앱 운영 상태는 .active, .inActive, .background 의 세 가지 경우 입니다.
  - 유저가 생각 기록 도중에 앱을 완전히 종료하거나 알 수 없는 이유로 앱이 종료되는 .suspend 상태까지는 scenePhase 환경 변수만으로 확인할 수 없었습니다. suspend 상태를 대응하기 위해서, 생각 기록을 로컬 데이터베이스에 저장하는 이벤트를 사유 저장 버튼 하나에만 바인딩하였습니다. 앱이 강제로 suspend되어 종료되는 상황에는, 그 시점까지 기록된 사유 내용이 임시 저장될 수 있도록 처리하고 유저가 앱에 다시 접속할 때 조회할 수 있도록 구현했습니다.

<br />

## 🚶 프로젝트 구현 화면

| 1. 앱 온보딩                                                                                              | 2. 오늘의 사유 구성1                                                                                      | 3. 오늘의 사유 구성2                                                                                      | 4. 오늘의 사유하기                                                                                        |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/6bb2d864-059a-419e-921f-9dfd6bb0e3ae" /> | <img width="200" src="https://github.com/user-attachments/assets/c4af4629-7f13-4fa1-83a5-445cd68abd2a" /> | <img width="200" src="https://github.com/user-attachments/assets/5c39d8df-edd5-4584-9d04-e4d5fe9eafbf" /> | <img width="200" src="https://github.com/user-attachments/assets/8358e269-0e6f-4acf-bbb0-006d0ada9347" /> |

- 앱을 처음 설치한 경우, 앱 기본 사항을 파악할 수 있는 온보딩 페이지가 노출됩니다.
  - 온보딩 단계에서는 걷기/달리기 모드에서 수집할 수 있는 모션 데이터에 대한 설명과 권한 부여에 대한 설명을 추가하였습니다.
- 오늘의 사유하기 View에서는, 사유를 기록하기 위해 필요한 주제, 세부 주제, 사유 방식 설정(걷기/달리기/앉아서), 사유 시간 설정, 스마트 목록 설정을 할 수 있습니다.
- 설정한 사유 방식(앉아서, 걸으면서, 달리면서)과 사유 시간 측정 방식(타이머/스톱워치)에 따라 오늘의 사유를 진행할 수 있습니다.

<br />

| 5. 캘린더 뷰                                                                                              | 6. 타임라인 뷰                                                                                            | 7. 사유 포인트 뷰                                                                                         | 8. 사유 기록 데이터                                                                                       |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/65f90abe-2b57-47f2-b598-ad4a701cb528" /> | <img width="200" src="https://github.com/user-attachments/assets/b654d465-cd55-4c91-9407-bcd1082a2e17" /> | <img width="200" src="https://github.com/user-attachments/assets/6ad7af90-606f-4790-a21c-94093d313b57" /> | <img width="200" src="https://github.com/user-attachments/assets/76cfc818-ec46-43e6-ac2a-57b735be1a3c" /> |

- 요일별로 작성한 사유 기록을 캘린더, 타임라인뷰로 조회할 수 있습니다.
  - 각각의 사유 기록을 터치하면 상세 내용을 확인할 수 있습니다.
  - 획득한 사유 포인트로 당일에 저장하지 못하고 넘어간 사유 기록을 다시 시작할 수 있습니다.
- 사유 작성, 앱 접속, 걸음 수 등의 조건으로 앱 내부에서 활용 가능한 사유 포인트를 수집할 수 있습니다.
- 기록된 사유 관련 데이터를 바 그래프나 수치 정보로 정리해서 확인할 수 있습니다.

<br />
