import 'package:equatable/equatable.dart';

sealed class AppSettingsAction extends Equatable {
  const AppSettingsAction();

  @override
  List<Object?> get props => [];
}

final class AppSettingsShowLanguageSheetAction extends AppSettingsAction {
  const AppSettingsShowLanguageSheetAction();
}

final class AppSettingsShowEraseDialogAction extends AppSettingsAction {
  const AppSettingsShowEraseDialogAction();
}

final class AppSettingsShowExportSheetAction extends AppSettingsAction {
  const AppSettingsShowExportSheetAction({required this.count});

  final int count;

  @override
  List<Object?> get props => [count];
}

final class AppSettingsShowImportSheetAction extends AppSettingsAction {
  const AppSettingsShowImportSheetAction();
}

final class ShowToast extends AppSettingsAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
