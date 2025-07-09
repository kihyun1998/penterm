enum TabType {
  home('home'),
  sftp('sftp'),
  terminal('terminal');

  const TabType(this.value);

  final String value;

  /// 탭 이름 (다국어 지원 시 여기서 처리)
  String get displayName {
    switch (this) {
      case TabType.home:
        return 'HOME';
      case TabType.sftp:
        return 'SFTP';
      case TabType.terminal:
        return 'Terminal';
    }
  }

  /// 탭 아이콘 (추후 SVG 아이콘 추가 시 사용)
  String get iconName {
    switch (this) {
      case TabType.home:
        return 'home';
      case TabType.sftp:
        return 'folder';
      case TabType.terminal:
        return 'terminal';
    }
  }

  /// JSON 직렬화
  String toJson() => value;

  /// JSON 역직렬화
  static TabType fromJson(String json) {
    return TabType.values.firstWhere(
      (type) => type.value == json,
      orElse: () => TabType.home,
    );
  }
}
