# Firebase 프로젝트 Xcode 연동 가이드

## 📱 프로젝트 정보
- **프로젝트 이름**: Ballog
- **Bundle ID**: `com.ballog.Ballog`
- **플랫폼**: iOS

## 🔥 Firebase 콘솔에서 iOS 앱 추가하기

### 1단계: Firebase 콘솔에서 iOS 앱 추가
1. [Firebase 콘솔](https://console.firebase.google.com/) 접속
2. "Ballog" 프로젝트 선택
3. 프로젝트 개요 페이지에서 **"iOS 아이콘"** 클릭
4. 앱 등록 정보 입력:
   ```
   iOS 번들 ID: com.ballog.Ballog
   앱 닉네임: Ballog (선택사항)
   App Store ID: (나중에 추가 가능)
   ```
5. **"앱 등록"** 버튼 클릭

### 2단계: GoogleService-Info.plist 다운로드
1. Firebase 콘솔에서 **"GoogleService-Info.plist 다운로드"** 클릭
2. 다운로드된 파일을 확인 (중요한 정보들이 포함되어 있음)

## 🔧 Xcode 프로젝트에 Firebase 연동하기

### 3단계: GoogleService-Info.plist 파일 교체
1. **Finder에서 다운로드한 GoogleService-Info.plist 파일을 찾기**
2. **기존 파일 백업**:
   ```bash
   cd /workspace/Ballog
   mv GoogleService-Info.plist GoogleService-Info.plist.backup
   ```
3. **새 파일을 프로젝트에 복사**:
   - 다운로드한 `GoogleService-Info.plist` 파일을 `/workspace/Ballog/` 폴더에 복사

### 4단계: Xcode에서 파일 추가 확인
1. **Xcode에서 Ballog.xcworkspace 열기** (중요: .xcworkspace 파일 사용)
   ```bash
   open Ballog.xcworkspace
   ```
2. Project Navigator에서 `GoogleService-Info.plist` 파일이 있는지 확인
3. 없다면 파일을 Xcode 프로젝트에 드래그 앤 드롭으로 추가
4. 파일 추가 시 옵션:
   - ✅ "Copy items if needed" 체크
   - ✅ "Ballog" 타겟 선택
   - ✅ "Create groups" 선택

### 5단계: Firebase 서비스 활성화
Firebase 콘솔에서 필요한 서비스들을 활성화:

1. **Firestore Database** (필수 - 코드에서 이미 사용):
   - 좌측 메뉴 > "Firestore Database" 클릭
   - "데이터베이스 만들기" 클릭
   - 보안 규칙: 우선 "테스트 모드"로 시작 (30일 후 자동 비활성화)
   - 위치: 가장 가까운 지역 선택

2. **Authentication** (선택 - 로그인 기능 사용 시):
   - 좌측 메뉴 > "Authentication" 클릭
   - "시작하기" 클릭
   - 필요한 로그인 방법 활성화 (이메일/비밀번호, 구글 등)

## 🔍 연동 확인하기

### 6단계: 빌드 테스트
1. **Xcode에서 프로젝트 빌드**:
   ```
   Product > Build (⌘+B)
   ```

2. **예상 결과**:
   - ✅ Firebase 모듈 import 성공
   - ✅ 컴파일 오류 없음
   - ✅ "No such module 'FirebaseCore'" 오류 해결됨

### 7단계: Firebase 초기화 확인
앱 실행 시 다음 로그가 콘솔에 출력되어야 함:
```
[Firebase/Core][I-COR000003] The default Firebase app has been configured.
```

## ⚠️ 주의사항

### Bundle ID 일치 확인
- Firebase 콘솔의 Bundle ID: `com.ballog.Ballog`
- Xcode 프로젝트의 Bundle ID: `com.ballog.Ballog`
- ✅ 일치함!

### 파일 위치 확인
```
프로젝트 구조:
Ballog/
├── Ballog.xcworkspace  ← 이 파일로 프로젝트 열기
├── Ballog.xcodeproj/
├── Ballog/
│   ├── GoogleService-Info.plist  ← 새 파일이 여기에 있어야 함
│   ├── App/
│   │   └── BallogApp.swift
│   └── ...
└── Pods/
```

## 🎯 완료 체크리스트

- [ ] Firebase 콘솔에서 iOS 앱 추가 완료
- [ ] GoogleService-Info.plist 다운로드 완료
- [ ] 기존 plist 파일을 새 파일로 교체 완료
- [ ] Xcode에서 파일이 올바른 타겟에 추가되었는지 확인
- [ ] Firestore Database 활성화 완료
- [ ] Xcode에서 빌드 테스트 성공
- [ ] 앱 실행 시 Firebase 초기화 로그 확인

## 🚨 문제 해결

### "GoogleService-Info.plist not found" 오류
1. 파일이 Xcode 프로젝트에 추가되었는지 확인
2. 파일이 "Ballog" 타겟에 포함되었는지 확인
3. 파일이 올바른 위치(`/Ballog/` 폴더)에 있는지 확인

### Firestore 연결 오류
1. Firebase 콘솔에서 Firestore Database가 활성화되었는지 확인
2. Bundle ID가 정확히 일치하는지 확인
3. 인터넷 연결 상태 확인

---

이 가이드를 따라하면 Firebase 프로젝트가 성공적으로 Xcode에 연동됩니다! 🎉