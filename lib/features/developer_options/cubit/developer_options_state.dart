import 'package:equatable/equatable.dart';
import 'package:mindful_links/features/developer_options/cubit/developer_options_action.dart';

export 'package:mindful_links/features/developer_options/cubit/developer_options_action.dart';

final class DeveloperOptionsState extends Equatable {
  const DeveloperOptionsState({required this.isMockStore, this.action});

  /// Whether the in-memory `MockUrlStore` is the active `UrlStore`.
  final bool isMockStore;
  final DeveloperOptionsAction? action;

  DeveloperOptionsState copyWith({
    bool? isMockStore,
    DeveloperOptionsAction? action,
    bool clearAction = false,
  }) {
    return DeveloperOptionsState(
      isMockStore: isMockStore ?? this.isMockStore,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  @override
  List<Object?> get props => [isMockStore, action];

  @override
  String toString() {
    return 'DeveloperOptionsState{isMockStore: $isMockStore, action: $action}';
  }
}
