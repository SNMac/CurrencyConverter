# CurrencyConverter

> 실시간 환율 정보를 Open API로 받아오고, 금액을 변환하거나, 관심 있는 통화를 즐겨찾기에 추가할수 있는 환율 계산기 앱입니다.
<br/>

## 📋 프로젝트 개요

실시간 데이터를 외부 API를 통해 받아온 뒤 그 데이터를 UI에 표시하고, 사용자의 입력을 바탕으로 새로운 결과를 계산하여 보여주는 것을 목표로 환율 계산기 앱을 개발하였습니다.
<br/>

## ⏰ 프로젝트 일정

- **시작일**: 25/04/14  
- **종료일**: 25/04/24
<br/>

## 🛠️ 기술 스택

### 아키텍처
- MVVM

### 비동기 처리
- RxSwift

### 데이터 처리
- CoreData

### API 통신
- URLSession

### 활용 API
- Exchange Rate API

### UI Frameworks
- UIKit
- SnapKit
- Then
<br/>

## 📱 프로젝트 구현 기능

1. 첫 번째 화면 : 메인 화면(환율 정보 - 환율 리스트)의 기초적인 UI 구현 + 데이터 불러오기
    - UI 디테일 : 다양한 기기에서 Landscape, Portrait 대응

2. 데이터 필터링 : 통화명, 국가명 등 기준의 데이터를 필터링

3. 화면 전환 : 환율 정보 네비게이션 바 (상단) 영역 구현. 스와이프로 두번째 화면 전환

4. 실시간 데이터 반영 : 화면에 입력된 금액을 실시간으로 환산

5. View와 로직 분리 : UI는 UI만, 로직은 로직만 담당할 수 있도록 분리

6. 데이터 저장 및 정렬 : 즐겨찾기 목록 저장, 즐겨찾기 상단 고정

7. 데이터 변화에 따른 UI 반영 : 환율데이터의 이전과 이후를 비교항 상승 하락 여부 표시

8. 다크모드 구현 : 정해진 색상을 컴포넌트별 적용

9. 앱 상태 저장 및 복원 : 사용자가 마지막 본 화면 기억 후 복귀
<br/>

## 실행 이미지

|    구현 내용    |   스크린샷   |    구현 내용    |   스크린샷   |
| :-------------: | :----------: | :-------------: | :----------: |
| 즐겨찾기 | <img src = "https://github.com/user-attachments/assets/df260268-6188-4508-99b4-ca4d2d719824" width ="250">| 환율 계산기 | <img src = "https://github.com/user-attachments/assets/68616839-7b55-43cf-b386-ac62033403fb" width ="250">|
| 앱 상태 저장 | <img src = "https://github.com/user-attachments/assets/71a10a05-6ecf-4123-a31b-efcc25612ec1" width ="250">| 다크모드 | <img src = "https://github.com/user-attachments/assets/464db5f1-2bc4-4e46-938f-3107766bf0be" width ="250">|
| 가로 화면 모드 | <img src = "https://github.com/user-attachments/assets/0908068a-dfaf-4e15-ab32-ceb7fbaa33a6" width ="250">| iPhone SE<br/>(3rd gen.) | <img src = "https://github.com/user-attachments/assets/5c126b3d-4989-448a-9af3-7ec7aa4ddee8" width ="250">|
<br/>
