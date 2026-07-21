import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';

/// PrimaryButton — filled action button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool loading;

  @override Widget build(BuildContext context) {
    final child = switch ((icon, loading)) {
      (_, true) => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
      (IconData i, false) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 18), const SizedBox(width: 8), Text(label)]),
      _ => Text(label),
    };

    if (expanded) {
      return SizedBox(width: double.infinity, height: DesignTokens.minTouchSize, child: FilledButton(onPressed: loading ? null : onPressed, child: child));
    }
    return FilledButton(onPressed: loading ? null : onPressed, child: child);
  }
}

/// SecondaryButton — tonal action button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.expanded = true});

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override Widget build(BuildContext context) {
    if (expanded) {
      return SizedBox(width: double.infinity, height: DesignTokens.minTouchSize, child: FilledButton.tonal(onPressed: onPressed, child: Text(label)));
    }
    return FilledButton.tonal(onPressed: onPressed, child: Text(label));
  }
}

/// OutlinedButton variant.
class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, required this.onPressed, this.expanded = true});

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override Widget build(BuildContext context) {
    if (expanded) {
      return SizedBox(width: double.infinity, height: DesignTokens.minTouchSize, child: OutlinedButton(onPressed: onPressed, child: Text(label)));
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}

/// StatusBadge — colored pill for status display.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color, this.small = false});

  final String label;
  final Color color;
  final bool small;

  @override Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 10, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 9 : 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
