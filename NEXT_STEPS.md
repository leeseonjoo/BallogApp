# 🔥 Firebase 연동 완료를 위한 다음 단계

## ✅ 이미 완료된 작업
- CocoaPods 및 Firebase 종속성 설치 ✅
- 기존 임시 GoogleService-Info.plist 파일 백업 ✅  
- Bundle ID 확인: `com.ballog.Ballog` ✅

## 🎯 지금 해야 할 일

### 1. Firebase 콘솔에서 iOS 앱 추가
[Firebase 콘솔](https://console.firebase.google.com/) > Ballog 프로젝트로 이동하여:

1. **iOS 앱 추가**:
   - iOS 아이콘 클릭
   - Bundle ID: `com.ballog.Ballog` 입력
   - 앱 닉네임: `Ballog` 입력
   - "앱 등록" 클릭

2. **GoogleService-Info.plist 다운로드**

### 2. 다운로드한 파일을 프로젝트에 복사
```bash
# 다운로드 폴더에서 프로젝트 폴더로 복사
cp ~/Downloads/GoogleService-Info.plist /workspace/Ballog/
```

### 3. Xcode에서 프로젝트 열기
```bash
open Ballog.xcworkspace
```
⚠️ **중요**: `.xcworkspace` 파일을 사용해야 합니다!

### 4. Xcode에서 파일 추가 확인
- Project Navigator에서 `GoogleService-Info.plist` 파일 확인
- 없다면 드래그 앤 드롭으로 추가
- "Ballog" 타겟에 포함되는지 확인

### 5. Firebase 서비스 활성화
Firebase 콘솔에서:
- **Firestore Database** 생성 (테스트 모드)
- **Authentication** 설정 (필요시)

### 6. 빌드 테스트
Xcode에서 `Product > Build` (⌘+B)

## 📝 상세 가이드
더 자세한 단계별 설명은 `FIREBASE_SETUP_GUIDE.md` 파일을 참고하세요.

---
**예상 소요 시간**: 10-15분
**완료 후**: 앱이 성공적으로 빌드되고 Firebase와 연동됩니다! 🎉