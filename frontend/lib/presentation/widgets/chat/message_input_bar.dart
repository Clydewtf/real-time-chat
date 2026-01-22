import 'package:flutter/material.dart';
import '../common/app_icon_button.dart';
import '../common/app_text_field.dart';
import '../constants/app_spacing.dart';
import '../../../core/utils/theme.dart';


class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;

  const MessageInputBar({
    super.key,
    required this.controller,
    this.onSend,
    this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          AppIconButton(icon: Icons.attach_file, onPressed: onAttach),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: AppTextField(
              controller: controller,
              hintText: 'Message',
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          AppIconButton(icon: Icons.send, onPressed: onSend, color: AppTheme.lightPrimary),
        ],
      ),
    );
  }
}