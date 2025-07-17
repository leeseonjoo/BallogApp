# Ballog iOS 앱 빌드 오류 해결 완료 가이드

## 🎯 해결된 문제들

### ✅ 1. CocoaPods 및 Firebase 종속성 설치 완료
- **문제**: `No such module 'FirebaseCore'` 오류
- **해결**: CocoaPods를 설치하고 `pod install` 실행 완료
- **상태**: ✅ 해결됨

### ✅ 2. Firebase 종속성 설치 확인
설치된 Firebase 모듈들:
- Firebase/Core ✅
- Firebase/Firestore ~> 10.15.0 ✅  
- FirebaseFirestoreSwift ~> 10.15.0 ✅

### ⚠️ 3. 남은 작업 (사용자가 직접 해야 할 것들)

## 🔧 필요한 추가 설정

### 1. LD_RUNPATH_SEARCH_PATHS 빌드 설정 수정
**문제**: CocoaPods 설치 후 경고 메시지
```
The `Ballog [Debug]` target overrides the `LD_RUNPATH_SEARCH_PATHS` build setting
```

**해결 방법**:
1. Xcode에서 프로젝트 열기 (`Ballog.xcworkspace` 파일 사용)
2. Project Navigator에서 `Ballog` 프로젝트 선택
3. `Ballog` 타겟 선택
4. `Build Settings` 탭으로 이동
5. `LD_RUNPATH_SEARCH_PATHS` 검색
6. Debug와 Release 설정에서 값을 `$(inherited)`로 변경하거나 기존 값에 `$(inherited)`를 추가

### 2. 실제 Firebase 프로젝트 설정
**현재 상태**: `GoogleService-Info.plist`에 임시 값들이 있음

**해결 방법**:
1. [Firebase 콘솔](https://console.firebase.google.com/) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. iOS 앱 추가:
   - Bundle ID: `com.yourcompany.ballog` (또는 프로젝트에 맞는 실제 Bundle ID)
   - 앱 닉네임: `Ballog`
4. `GoogleService-Info.plist` 다운로드
5. 기존 `/Ballog/GoogleService-Info.plist` 파일을 새 파일로 교체
6. Xcode에서 파일이 올바른 타겟에 추가되었는지 확인

### 3. Firebase 서비스 활성화
Firebase 콘솔에서 다음 서비스들을 활성화:
- ✅ **Firestore Database** (이미 코드에서 사용 중)
- 📱 **Authentication** (필요한 경우)
- 📊 **Analytics** (선택사항)

## 🚀 빌드 확인 단계

### 1. 프로젝트 열기
```bash
# .xcworkspace 파일을 사용해야 함 (CocoaPods 사용 시 필수)
open Ballog.xcworkspace
```

### 2. 빌드 테스트
1. Xcode에서 `Product > Build` (⌘+B)
2. 시뮬레이터 선택 후 `Product > Run` (⌘+R)

### 3. 예상되는 성공 상태
- ✅ Firebase 모듈 import 성공
- ✅ 컴파일 오류 없음
- ✅ 앱 실행 가능

## 📋 체크리스트

### 개발 환경 설정
- [x] Ruby 설치 완료
- [x] CocoaPods 설치 완료
- [x] `pod install` 실행 완료
- [x] Firebase 종속성 설치 완료

### 프로젝트 설정 (사용자가 해야 할 일)
- [ ] LD_RUNPATH_SEARCH_PATHS 빌드 설정 수정
- [ ] 실제 Firebase 프로젝트 생성
- [ ] 실제 GoogleService-Info.plist 파일로 교체
- [ ] Firestore Database 설정
- [ ] 빌드 테스트 및 확인

## 🔍 문제가 계속 발생하는 경우

### 일반적인 해결 방법
1. **Clean Build**: Xcode에서 `Product > Clean Build Folder` (⌘+Shift+K)
2. **Derived Data 삭제**: `~/Library/Developer/Xcode/DerivedData` 폴더 내용 삭제
3. **Pod 재설치**:
   ```bash
   pod deintegrate
   pod install
   ```

### Firebase 관련 문제
1. **GoogleService-Info.plist 위치 확인**: 파일이 프로젝트 루트에 있고 타겟에 포함되어 있는지 확인
2. **Bundle ID 일치 확인**: Firebase 콘솔의 Bundle ID와 Xcode 프로젝트의 Bundle ID가 일치하는지 확인
3. **Firebase 초기화 확인**: `FirebaseApp.configure()` 호출이 올바른 위치에 있는지 확인

## 🎉 완료!

모든 단계를 완료하면 Ballog iOS 앱이 성공적으로 빌드되고 실행될 것입니다.

---

**마지막 업데이트**: Firebase 종속성 설치 및 CocoaPods 설정 완료
**다음 단계**: 위의 "필요한 추가 설정" 섹션을 따라 나머지 설정 완료