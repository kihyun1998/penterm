/// 터미널 드래그 시작점을 구분하는 enum
enum DragSource {
  tab, // 탭바에서 드래그 시작
  panel, // 패널에서 드래그 시작
}

/// 통합된 터미널 드래그 데이터
/// 탭 드래그와 패널 드래그를 하나로 통합
class TerminalDragData {
  /// 드래그되는 터미널의 ID
  final String terminalId;

  /// 표시될 이름 (UI용)
  final String displayName;

  /// 드래그가 시작된 위치 (탭 또는 패널)
  final DragSource source;

  const TerminalDragData({
    required this.terminalId,
    required this.displayName,
    required this.source,
  });

  /// 탭에서 드래그된 데이터인지 확인
  bool get isFromTab => source == DragSource.tab;

  /// 패널에서 드래그된 데이터인지 확인
  bool get isFromPanel => source == DragSource.panel;

  /// 디버그용 문자열 표현
  String get debugInfo => '$displayName (from ${source.name})';

  TerminalDragData copyWith({
    String? terminalId,
    String? displayName,
    DragSource? source,
  }) {
    return TerminalDragData(
      terminalId: terminalId ?? this.terminalId,
      displayName: displayName ?? this.displayName,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TerminalDragData &&
        other.terminalId == terminalId &&
        other.displayName == displayName &&
        other.source == source;
  }

  @override
  int get hashCode => Object.hash(terminalId, displayName, source);

  @override
  String toString() => 'TerminalDragData($debugInfo)';
}
