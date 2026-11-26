import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_links/common/widgets/sheet_drag_handle.dart';
import 'package:keep_links/core/utils/app_defaults.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_bloc.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_event.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_state.dart';
import 'package:keep_links/features/theme/theme.dart';
import 'package:keep_links/utils/utils.dart';

class CreateFolderSheetWidget extends StatelessWidget {
  const CreateFolderSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateFolderBloc, CreateFolderState>(
      listenWhen: (previous, current) =>
          current.action != null && previous.action != current.action,
      listener: (context, state) {
        final action = state.action;
        if (action == null) return;

        if (action is ShowToast) {
          Utils.showToast(action.message);
        } else if (action is CloseWithMessage) {
          Utils.showToast(action.message);
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            Navigator.pop(context);
          }
          return;
        }

        context.read<CreateFolderBloc>().add(const OnActionHandled());
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetDragHandle(),
                  const SizedBox(height: 16),
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildNameField(context),
                  const SizedBox(height: 16),
                  _buildCreateButton(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Folder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1B18),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Organize links into a bespoke space',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF857B74),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    final bloc = context.read<CreateFolderBloc>();

    return TextField(
      autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(AppDefaults.folderNameMaxLength),
      ],
      textInputAction: TextInputAction.done,
      onChanged: (value) => bloc.add(OnNameChanged(value)),
      onSubmitted: (_) => bloc.add(const OnCreateClicked()),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF1E1B18),
      ),
      decoration: InputDecoration(
        hintText: 'Folder name',
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9E8E85),
        ),
        prefixIcon: const Icon(
          Icons.folder_outlined,
          size: 20,
          color: Color(0xFF52443D),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: _buildFieldBorder(const Color(0xFFE0D5CE), width: 1),
        focusedBorder: _buildFieldBorder(KeepLinksTheme.primary, width: 1),
      ),
    );
  }

  OutlineInputBorder _buildFieldBorder(Color color, {required double width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildCreateButton(BuildContext context, CreateFolderState state) {
    const enabledColor = Color(0xFF7A4326);
    const disabledColor = Color(0xFF9E8E85);

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: KeepLinksTheme.primary,
        foregroundColor: enabledColor,
        disabledBackgroundColor: KeepLinksTheme.primary.withValues(alpha: 0.5),
        disabledForegroundColor: disabledColor,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: state.isCreateEnabled
          ? () => context.read<CreateFolderBloc>().add(const OnCreateClicked())
          : null,
      icon: state.isCreating
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: enabledColor,
              ),
            )
          : const Icon(Icons.create_new_folder_outlined, size: 20),
      label: const Text(
        'Create Folder',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
