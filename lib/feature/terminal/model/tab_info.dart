// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'enum_tab_type.dart';

/// 개별 탭 정보를 담는 클래스
class TabInfo {
  final String id;
  final TabType type;
  final String name;
  final bool isClosable;
  // 🚀 order 필드 완전 제거 - List index가 순서를 담당

  const TabInfo({
    required this.id,
    required this.type,
    required this.name,
    this.isClosable = true,
  });

  TabInfo copyWith({
    String? id,
    TabType? type,
    String? name,
    bool? isClosable,
  }) {
    return TabInfo(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isClosable: isClosable ?? this.isClosable,
    );
  }
}
