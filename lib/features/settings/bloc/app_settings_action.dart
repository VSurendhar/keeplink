import 'package:equatable/equatable.dart';

sealed class AppSettingsAction extends Equatable {
  const AppSettingsAction();

  @override
  List<Object?> get props => [];
}

final class ShowLanguageSheet extends AppSettingsAction {
  const ShowLanguageSheet();
}

final class ShowMoveAllToTrashDialog extends AppSettingsAction {
  const ShowMoveAllToTrashDialog();
}

final class ShowExportSheet extends AppSettingsAction {
  const ShowExportSheet({required this.count});

  final int count;

  @override
  List<Object?> get props => [count];
}

final class ShowImportSheet extends AppSettingsAction {
  const ShowImportSheet();
}

final class ShowToast extends AppSettingsAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
