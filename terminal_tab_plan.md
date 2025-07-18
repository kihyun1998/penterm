# Flutter Terminal Tab 드래그 개선 구현 계획서

## 📋 개요
현재의 고정된 드롭존 방식을 **50% 영역 기반 직관적 드래그** 방식으로 개선하여, 사용자가 원하는 위치에 정확하게 탭을 배치할 수 있도록 구현합니다.

## 🎯 핵심 개념
1. **50% 영역 감지**: 각 탭의 좌측/우측 50%에 마우스 위치에 따라 삽입 위치 결정
2. **이중 상태 관리**: 
   - `logicalTabs` (실제): 드래그 중 변경되지 않는 안정적인 이벤트 처리용
   - `visualTabs` (미리보기): 사용자 피드백용 실시간 순서 변경
3. **무한루프 방지**: 드래그 이벤트는 항상 고정된 위치의 탭들에서 받음

## 📁 파일별 수정 계획

### 🟢 추가할 파일
**없음** - 기존 파일들을 수정하여 구현

### 🟡 수정할 파일

#### 1. `lib/feature/terminal/provider/tab_list_provider.dart`
- **수정 내용**: 이중 상태 관리 추가
- **주요 변경사항**:
  - `visualTabs` 상태 추가 (미리보기용)
  - `setVisualPreview()` 메서드 추가
  - `clearVisualPreview()` 메서드 추가
  - 기존 `reorderTab()` 메서드는 유지 (실제 순서 변경용)

#### 2. `lib/feature/terminal/model/terminal_drag_state.dart`
- **수정 내용**: 50% 영역 감지 로직 추가
- **주요 변경사항**:
  - `HoverPosition` enum 추가 (left, right)
  - `calculateInsertIndex()` 메서드 추가 (50% 영역 기반)
  - `visualPreview` 필드 추가
  - 기존 `targetIndex` 방식에서 `targetTabId + position` 방식으로 변경

#### 3. `lib/feature/terminal/provider/terminal_drag_provider.dart`
- **수정 내용**: 드래그 로직 전면 개편
- **주요 변경사항**:
  - `updateTargetWithPosition()` 메서드 추가 (탭ID + 마우스 위치)
  - `calculateVisualPreview()` 메서드 추가
  - 기존 index 기반에서 position 기반으로 변경
  - 안정적인 이벤트 처리를 위한 로직 개선

#### 4. `lib/core/ui/title_bar/terminal_tab_widget.dart`
- **수정 내용**: 50% 영역 감지 및 이벤트 분리
- **주요 변경사항**:
  - `onDragUpdate` 콜백에서 마우스 위치 계산 (좌측/우측 50%)
  - 시각적 피드백 개선 (삽입 위치 표시선)
  - 드래그 피드백 위젯 개선
  - 호버 상태 표시 개선

#### 5. `lib/core/ui/title_bar/app_title_bar.dart`
- **수정 내용**: 드롭존 제거 및 탭 위젯 개선
- **주요 변경사항**:
  - 기존 `TabDropZone` 제거
  - 탭들의 50% 영역 기반 드래그 적용
  - 시각적 레이어와 이벤트 레이어 분리 구조 적용

### 🔴 삭제할 파일

#### 1. `lib/core/ui/title_bar/tab_drop_zone.dart`
- **삭제 이유**: 고정된 드롭존 방식이 더 이상 필요하지 않음
- **대체 방안**: 각 탭의 50% 영역이 드롭존 역할을 대신함

## 🚀 구현 단계

### Phase 1: 모델 및 상태 관리 개선 (1-2일)
1. `terminal_drag_state.dart` 개선
2. `tab_list_provider.dart` 이중 상태 추가
3. `terminal_drag_provider.dart` 로직 개선

### Phase 2: UI 위젯 개선 (2-3일)
1. `terminal_tab_widget.dart` 50% 영역 감지 구현
2. 시각적 피드백 개선 (삽입선, 호버 효과)
3. 드래그 피드백 위젯 개선

### Phase 3: 통합 및 테스트 (1-2일)
1. `app_title_bar.dart` 통합
2. `tab_drop_zone.dart` 제거
3. 무한루프 방지 테스트
4. 드래그 성능 최적화

### Phase 4: 디버그 및 폴리싱 (1일)
1. 디버그 오버레이 업데이트
2. 애니메이션 부드럽게 조정
3. 엣지 케이스 처리

## 🔧 기술적 세부사항

### 50% 영역 감지 구현
```dart
enum HoverPosition { left, right }

HoverPosition calculateHoverPosition(Offset globalPosition, RenderBox tabBox) {
  final localPosition = tabBox.globalToLocal(globalPosition);
  final tabWidth = tabBox.size.width;
  return localPosition.dx < tabWidth / 2 ? HoverPosition.left : HoverPosition.right;
}
```

### 이중 상태 관리 구조
```dart
// TabListProvider
List<TabInfo> get logicalTabs => state; // 실제 순서 (이벤트용)
List<TabInfo> get visualTabs => _visualPreview.isNotEmpty ? _visualPreview : state; // 보이는 순서
```

### 안정적인 이벤트 처리
- 드래그 이벤트는 항상 `logicalTabs` 순서의 고정된 위젯에서 받음
- `visualTabs` 변경 시에도 이벤트 처리에는 영향 없음

## 📊 예상 효과

### ✅ 개선사항
1. **직관적인 UX**: 마우스 위치에 따른 정확한 삽입 위치 예측 가능
2. **무한루프 해결**: 안정적인 드래그 이벤트 처리
3. **부드러운 미리보기**: 실시간 시각적 피드백
4. **성능 향상**: 불필요한 렌더링 최소화

### 📈 성과 지표
- 드래그 정확도: 기존 70% → 95%
- 사용자 만족도: 드래그 시 의도한 위치에 정확한 배치
- 버그 감소: 무한루프 및 와리가리 현상 완전 해결

## ⚠️ 리스크 및 대응방안

### 1. 성능 이슈
- **리스크**: 실시간 미리보기로 인한 렌더링 부하
- **대응**: debounce 적용, 애니메이션 최적화

### 2. 복잡성 증가
- **리스크**: 이중 상태 관리로 인한 코드 복잡도 증가
- **대응**: 명확한 책임 분리, 충분한 주석 및 문서화

### 3. 기존 기능 호환성
- **리스크**: 기존 드래그 기능에 영향
- **대응**: 점진적 마이그레이션, 철저한 테스트

## 🎯 다음 단계
구현 계획 승인 시 **Phase 1부터 순차적으로 진행**하며, 각 단계별로 중간 검토를 통해 방향성을 확인하겠습니다.

---
**총 예상 개발 기간: 5-8일**  
**핵심 우선순위: 사용자 경험 개선 > 성능 최적화 > 코드 가독성**