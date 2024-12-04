# Melendar (Memo + Calendar)

## 📖 프로젝트 소개
현대인들에게 수많은 개인 및 협업 일정 관리의 중요성이 점점 커지고 있습니다.  
**Melendar**는 개인 일정과 메모뿐만 아니라 **그룹 단위의 일정 관리**까지 한 번에 처리할 수 있는  
**메모 및 캘린더 기능을 통합**한 모바일 애플리케이션입니다.

---

## 🌟 주요 기능

### 1. **로그인 화면**
- 구글 계정을 통한 로그인
- 간편한 인증 시스템 제공

<img src="https://github.com/user-attachments/assets/58433ffa-57ee-41b3-9d63-e8f47b5a30ce" alt="로그인" width="300" style="display: block; margin: auto;">

---

### 2. **사용자 정보 화면**
- 사용자 정보 출력
- 닉네임 및 프로필 이미지 수정 가능
- 로그아웃 기능

<img src="https://github.com/user-attachments/assets/c5d6b612-eb6b-44d5-9baa-51a9f468a72d" alt="내 정보" width="300" style="display: block; margin: auto;">

---

### 3. **캘린더**
- 일정 관리: 일정 추가, 삭제, 수정, 검색
- 특정 그룹의 일정만 확인 가능

<img src="https://github.com/user-attachments/assets/dc9177c0-84d5-455d-a22c-0aaf57a92dbc" alt="캘린더" width="300" style="display: block; margin: auto;">

---

### 4. **그룹 관리**
- 유저 ID를 통한 그룹원 추가
- 그룹 추가, 삭제, 검색, 수정

<img src="https://github.com/user-attachments/assets/56242895-b3d3-4f04-ad3e-9c8a9bee357b" alt="그룹" width="300" style="display: block; margin: auto;">

---

### 5. **메모 관리**
- 메모 추가, 삭제, 수정, 검색
- 개인 메모만 확인 가능

<img src="https://github.com/user-attachments/assets/5e6de989-53c7-40e9-a9c0-741929699489" alt="메모" width="300" style="display: block; margin: auto;">

---

## 🧑‍💻 팀원 소개

| 이름       | 담당 영역                                  |
|------------|------------------------------------------|
| **이승언** | 캘린더 화면 및 그룹 화면 구현               |
| **전지훈** | 로그인 화면 및 메모 화면 구현               |
| **석종수** | `group`, `calendar` API 호출 로직 구현       |
| **조석원** | 내 정보 화면 및 `user`, `memo` API 호출 로직 구현 |

---

## 🔧 주요 기능 및 사용된 패키지 버전

| 주요 기능                | 관련 패키지          | 버전     |
|-------------------------|---------------------|---------|
| Firebase 초기화      | `firebase_core`     | ^3.7.0  |
| 실시간 데이터베이스   | `cloud_firestore`    | ^5.4.4  |
| 사용자 인증          | `firebase_auth`     | ^5.3.2  |
| 파일 업로드 및 저장소 | `firebase_storage`  | ^12.3.5 |
| 구글 로그인          | `google_sign_in`    | ^6.1.4  |
| 캘린더 UI           | `calendar_view`     | ^1.2.0  |
| 파일 및 이미지 선택   | `image_picker`      | ^1.0.0  |
| 하단 네비게이션 바    | `salomon_bottom_bar`| ^3.3.2  |

---

## 🛠️ 개발 환경

| 구성 요소               | 사용된 기술 및 도구          | 설명                                     |
|-----------------------|------------------------|----------------------------------------|
| 화면 (Frontend)    | Flutter                | - 모바일 애플리케이션 화면 구현 |
| DB 연동 (Backend)  | Flutter                | - Firestore와 직접 통신<br>- Firebase SDK를 사용해 데이터 처리 |
| 데이터베이스 (DB)   | Firestore Database     | - Firebase 실시간 데이터베이스<br>- 데이터 추가, 수정, 삭제, 조회 관리 |
| 회의 및 협업        | Discord                | - 비대면 회의 진행 |
| 버전 관리          | GitHub                 | - 소스 코드 관리 및 협업 |

---
