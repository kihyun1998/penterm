// ignore_for_file: public_member_api_docs, sort_constructors_first

/// 분할 방향
enum SplitType {
  none, // 분할 없음 (일반 탭)
  horizontal, // 좌우 분할 (세로선으로 나뉨)
  vertical; // 상하 분할 (가로선으로 나뉨)

  /// 분할이 활성화되어 있는지
  bool get isSplit => this != SplitType.none;

  /// JSON 직렬화
  String toJson() => name;

  /// JSON 역직렬화
  static SplitType fromJson(String json) {
    return SplitType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => SplitType.none,
    );
  }
}

/// 개별 패널 정보
class PanelInfo {
  final String id;
  final String? terminalId; // 이 패널에 할당된 터미널 ID
  final PanelPosition position; // 패널 위치
  final bool isActive; // 현재 활성 패널인지

  const PanelInfo({
    required this.id,
    this.terminalId,
    required this.position,
    this.isActive = false,
  });

  /// 빈 패널인지 확인
  bool get isEmpty => terminalId == null;

  /// 터미널이 할당된 패널인지 확인
  bool get hasTerminal => terminalId != null;

  PanelInfo copyWith({
    String? id,
    String? terminalId,
    PanelPosition? position,
    bool? isActive,
  }) {
    return PanelInfo(
      id: id ?? this.id,
      terminalId: terminalId ?? this.terminalId,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
    );
  }

  /// 터미널 할당
  PanelInfo assignTerminal(String terminalId) {
    return copyWith(terminalId: terminalId);
  }

  /// 터미널 해제 (빈 패널로 만들기)
  PanelInfo clearTerminal() {
    return copyWith(terminalId: null);
  }

  /// 활성화
  PanelInfo activate() {
    return copyWith(isActive: true);
  }

  /// 비활성화
  PanelInfo deactivate() {
    return copyWith(isActive: false);
  }
}

/// 패널 위치
enum PanelPosition {
  // 좌우 분할 시
  left, // 왼쪽 패널
  right, // 오른쪽 패널

  // 상하 분할 시
  top, // 위쪽 패널
  bottom; // 아래쪽 패널

  /// 좌우 분할 패널인지
  bool get isHorizontalSplit =>
      this == PanelPosition.left || this == PanelPosition.right;

  /// 상하 분할 패널인지
  bool get isVerticalSplit =>
      this == PanelPosition.top || this == PanelPosition.bottom;

  /// 첫 번째 패널인지 (left, top)
  bool get isFirst => this == PanelPosition.left || this == PanelPosition.top;

  /// 두 번째 패널인지 (right, bottom)
  bool get isSecond =>
      this == PanelPosition.right || this == PanelPosition.bottom;

  /// 반대 위치 반환
  PanelPosition get opposite {
    switch (this) {
      case PanelPosition.left:
        return PanelPosition.right;
      case PanelPosition.right:
        return PanelPosition.left;
      case PanelPosition.top:
        return PanelPosition.bottom;
      case PanelPosition.bottom:
        return PanelPosition.top;
    }
  }

  /// SplitType에 맞는 PanelPosition 목록
  static List<PanelPosition> forSplitType(SplitType splitType) {
    switch (splitType) {
      case SplitType.horizontal:
        return [PanelPosition.left, PanelPosition.right];
      case SplitType.vertical:
        return [PanelPosition.top, PanelPosition.bottom];
      case SplitType.none:
        return [];
    }
  }
}

/// 분할 레이아웃 상태
class SplitLayoutState {
  final String activeTabId; // 현재 활성 탭 ID
  final SplitType splitType; // 분할 방식
  final Map<String, PanelInfo> panels; // 패널 정보 (패널 ID -> 패널 정보)
  final String? activePanelId; // 현재 활성 패널 ID

  const SplitLayoutState({
    required this.activeTabId,
    this.splitType = SplitType.none,
    this.panels = const {},
    this.activePanelId,
  });

  /// 초기 상태 (분할 없음)
  static const SplitLayoutState initial = SplitLayoutState(
    activeTabId: 'home',
  );

  /// 분할이 활성화되어 있는지
  bool get isSplit => splitType.isSplit;

  /// 패널 개수
  int get panelCount => panels.length;

  /// 모든 패널 목록 (위치 순서대로 정렬)
  List<PanelInfo> get orderedPanels {
    final panelList = panels.values.toList();

    if (splitType == SplitType.horizontal) {
      // 좌우 분할: left -> right 순서
      panelList.sort((a, b) {
        if (a.position == PanelPosition.left) return -1;
        if (b.position == PanelPosition.left) return 1;
        return 0;
      });
    } else if (splitType == SplitType.vertical) {
      // 상하 분할: top -> bottom 순서
      panelList.sort((a, b) {
        if (a.position == PanelPosition.top) return -1;
        if (b.position == PanelPosition.top) return 1;
        return 0;
      });
    }

    return panelList;
  }

  /// 특정 위치의 패널 반환
  PanelInfo? getPanelByPosition(PanelPosition position) {
    return panels.values
        .where((panel) => panel.position == position)
        .firstOrNull;
  }

  /// 특정 터미널이 할당된 패널 반환
  PanelInfo? getPanelByTerminal(String terminalId) {
    return panels.values
        .where((panel) => panel.terminalId == terminalId)
        .firstOrNull;
  }

  /// 현재 활성 패널 반환
  PanelInfo? get activePanel {
    return activePanelId != null ? panels[activePanelId] : null;
  }

  /// 빈 패널 목록
  List<PanelInfo> get emptyPanels {
    return panels.values.where((panel) => panel.isEmpty).toList();
  }

  /// 터미널이 할당된 패널 목록
  List<PanelInfo> get occupiedPanels {
    return panels.values.where((panel) => panel.hasTerminal).toList();
  }

  /// 첫 번째 빈 패널 반환 (터미널 자동 할당용)
  PanelInfo? get firstEmptyPanel {
    return emptyPanels.isNotEmpty ? emptyPanels.first : null;
  }

  SplitLayoutState copyWith({
    String? activeTabId,
    SplitType? splitType,
    Map<String, PanelInfo>? panels,
    String? activePanelId,
  }) {
    return SplitLayoutState(
      activeTabId: activeTabId ?? this.activeTabId,
      splitType: splitType ?? this.splitType,
      panels: panels ?? this.panels,
      activePanelId: activePanelId ?? this.activePanelId,
    );
  }

  /// 디버그 정보
  String get debugInfo {
    return '''
Active Tab: $activeTabId
Split Type: ${splitType.name}
Panel Count: $panelCount
Active Panel: $activePanelId
Panels:
${panels.entries.map((e) => '  ${e.key}: ${e.value.position.name} (terminal: ${e.value.terminalId ?? 'empty'}) ${e.value.isActive ? '[ACTIVE]' : ''}').join('\n')}
''';
  }
}
