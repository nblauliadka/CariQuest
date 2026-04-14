// lib/shared/widgets/status_chip.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';

class StatusChip extends StatelessWidget {
  final QuestStatus? status;
  final Color? color;
  final String? label;

  const StatusChip({
    super.key,
    this.status,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = color?.withOpacity(0.1) ?? Colors.grey.shade100;
    Color textColor = color ?? Colors.grey.shade800;
    String text = label ?? 'Unknown';

    if (status != null) {
      switch (status!) {
        case QuestStatus.pending:
          bgColor = Colors.orange.shade100;
          textColor = Colors.orange.shade800;
          text = 'Mencari Expert';
          break;
        case QuestStatus.paid:
          bgColor = Colors.indigo.shade100;
          textColor = Colors.indigo.shade800;
          text = 'Dana di Escrow';
          break;
        case QuestStatus.working:
          bgColor = Colors.purple.shade100;
          textColor = Colors.purple.shade800;
          text = 'Sedang Dikerjakan';
          break;
        case QuestStatus.review:
          bgColor = Colors.cyan.shade100;
          textColor = Colors.cyan.shade800;
          text = 'Review Hasil';
          break;
        case QuestStatus.finished:
          bgColor = Colors.green.shade100;
          textColor = Colors.green.shade800;
          text = 'Selesai';
          break;
        case QuestStatus.disputed:
          bgColor = Colors.red.shade100;
          textColor = Colors.red.shade800;
          text = 'Banding';
          break;
        case QuestStatus.cancelled:
          bgColor = Colors.grey.shade300;
          textColor = Colors.grey.shade800;
          text = 'Dibatalkan';
          break;
      }
    }

    if (color != null) {
      bgColor = color!.withOpacity(0.1);
      textColor = color!;
    }
    if (label != null) {
      text = label!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
