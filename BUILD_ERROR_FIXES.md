# Ballog iOS 앱 빌드 에러 해결 가이드

## 발견된 빌드 에러 원인들

### 1. 🔥 Firebase 초기화 누락 (해결됨)
**문제**: `BallogApp.swift`에서 Firebase를 사용하고 있지만 `FirebaseApp.configure()`를 호출하지 않음
**해결**: 
- `import FirebaseCore` 추가
- `init()` 메서드에서 `FirebaseApp.configure()` 호출 추가

```swift
// 수정된 코드
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import SwiftData

@main
struct BallogApp: App {
    // Firebase 초기화
    init() {
        FirebaseApp.configure()
    }
    // ... 나머지 코드
}
```

### 2. 📄 GoogleService-Info.plist 파일 누락 (해결됨)
**문제**: Firebase 설정 파일이 프로젝트에 없음
**해결**: 
- 임시 `GoogleService-Info.plist` 파일 생성
- **중요**: 실제 Firebase 콘솔에서 다운로드한 파일로 교체 필요

**다음 단계**:
1. [Firebase 콘솔](https://console.firebase.google.com/)에서 프로젝트 생성
2. iOS 앱 추가 
3. Bundle ID는 `com.yourcompany.ballog` 또는 프로젝트에 맞게 설정
4. `GoogleService-Info.plist` 다운로드 후 기존 파일 교체

### 3. ⚙️ 프로젝트 설정 확인사항

#### Swift 버전 호환성
- 현재 설정: Swift 5.0
- Firebase 10.15.0과 호환됨 ✅

#### iOS 버전 타겟
- Platform: iOS 15.0
- Deployment Target: iOS 12.0 (Podfile에서 강제 설정)
- Firebase 10.15.0과 호환됨 ✅

#### CocoaPods 의존성
```ruby
# Podfile 현재 설정
pod 'Firebase/Core'
pod 'Firebase/Firestore', '~> 10.15.0'
pod 'FirebaseFirestoreSwift', '~> 10.15.0'
```

### 4. 🛠️ 추가 수정이 필요한 부분들

#### A. Bundle Identifier 설정
프로젝트 설정에서 Bundle Identifier를 실제 앱에 맞게 설정:
- 현재 임시: `com.yourcompany.ballog`
- 권장: `com.[회사명].ballog` 형태

#### B. Firebase 프로젝트 설정
GoogleService-Info.plist에서 다음 값들을 실제 값으로 교체:
- `YOUR_CLIENT_ID`
- `YOUR_REVERSED_CLIENT_ID`
- `YOUR_API_KEY`
- `YOUR_GCM_SENDER_ID`
- `YOUR_GOOGLE_APP_ID`
- `your-project-id`

#### C. 권한 설정 확인
`Info.plist`에서 다음 권한들이 설정되어 있는지 확인:
- HealthKit 사용 권한 (앱에서 HealthKitManager 사용)
- 네트워크 권한 (Firebase 연결용)

### 5. 🔍 잠재적 빌드 에러들

#### A. 누락된 모델 클래스들
다음 클래스들이 참조되고 있는지 확인:
- ✅ `Item` (SwiftData 모델)
- ✅ `ContentView`
- ✅ `LoginView`
- ✅ `HealthKitManager`

#### B. Firebase 서비스 클래스들
- ✅ `FirestoreAccountService`
- ✅ Store 클래스들 (AttendanceStore, TeamStore 등)

### 6. 🚀 빌드 실행 전 체크리스트

1. **Firebase 설정**
   - [ ] 실제 GoogleService-Info.plist 파일로 교체
   - [ ] Firebase 콘솔에서 Firestore 데이터베이스 생성
   - [ ] Bundle ID가 Firebase 프로젝트와 일치하는지 확인

2. **CocoaPods 설정**
   ```bash
   pod install --repo-update
   ```

3. **Xcode 설정**
   - [ ] Bundle Identifier 설정
   - [ ] 코드 서명 설정
   - [ ] 시뮬레이터 또는 기기 선택

4. **빌드 실행**
   ```bash
   # Xcode가 설치된 환경에서
   xcodebuild -workspace Ballog.xcworkspace -scheme Ballog -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
   ```

### 7. 📝 추가 개선사항

#### A. 에러 처리 개선
Firebase 초기화 실패 시 에러 처리:
```swift
init() {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
}
```

#### B. 환경별 설정
개발/프로덕션 환경에 따른 Firebase 프로젝트 분리 고려

#### C. 로깅 시스템
Firebase 연결 상태 및 에러 로깅 추가

---
**참고**: 이 문서는 현재 Linux 환경에서 분석한 결과입니다. 실제 빌드는 Xcode가 설치된 macOS 환경에서 진행해야 합니다.