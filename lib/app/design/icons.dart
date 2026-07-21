import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Centralized icon mapping for all Paysa domains.
///
/// Use these icon functions instead of hardcoding IconData in widgets.
/// Ensures consistent iconography across the app.
final class PaysaIcons {
  const PaysaIcons._();

  // Finance
  static IconData get account => Icons.account_balance_wallet_outlined;
  static IconData get accountFilled => Icons.account_balance_wallet;
  static IconData get income => Icons.arrow_circle_up_outlined;
  static IconData get expense => Icons.arrow_circle_down_outlined;
  static IconData get transfer => Icons.swap_horiz_outlined;
  static IconData get category => Icons.category_outlined;
  static IconData get budget => Icons.account_balance_outlined;
  static IconData get goal => Icons.track_changes_outlined;
  static IconData get cash => Icons.money_outlined;

  // Ledger
  static IconData get person => Icons.person_outlined;
  static IconData get personFilled => Icons.person;
  static IconData get people => Icons.people_outlined;
  static IconData get give => Icons.arrow_upward_outlined;
  static IconData get receive => Icons.arrow_downward_outlined;
  static IconData get sale => Icons.shopping_cart_outlined;
  static IconData get purchase => Icons.shopping_bag_outlined;
  static IconData get adjustment => Icons.tune_outlined;
  static IconData get discount => Icons.discount_outlined;
  static IconData get ledger => Icons.receipt_long_outlined;
  static IconData get reminder => Icons.notifications_outlined;

  // Payment
  static IconData get payment => Icons.payment_outlined;
  static IconData get paymentMethod => Icons.credit_card_outlined;
  static IconData get link => Icons.link_outlined;
  static IconData get qrCode => Icons.qr_code_outlined;
  static IconData get receipt => Icons.receipt_outlined;
  static IconData get refund => Icons.keyboard_return_outlined;

  // Navigation
  static IconData get dashboard => Icons.dashboard_outlined;
  static IconData get dashboardFilled => Icons.dashboard;
  static IconData get transactions => Icons.swap_horiz_outlined;
  static IconData get reports => Icons.pie_chart_outline_outlined;
  static IconData get settings => Icons.settings_outlined;
  static IconData get search => Icons.search;
  static IconData get close => Icons.close;
  static IconData get more => Icons.more_horiz_outlined;

  // Actions
  static IconData get add => Icons.add;
  static IconData get edit => Icons.edit_outlined;
  static IconData get delete => Icons.delete_outline;
  static IconData get archive => Icons.archive_outlined;
  static IconData get restore => Icons.restore_outlined;
  static IconData get share => Icons.share_outlined;
  static IconData get download => Icons.file_download_outlined;
  static IconData get favorite => Icons.star;
  static IconData get favoriteOutline => Icons.star_outline;
  static IconData get filter => Icons.filter_list_outlined;
  static IconData get sort => Icons.sort_outlined;

  // Communication
  static IconData get phone => Icons.phone_outlined;
  static IconData get email => Icons.email_outlined;
  static IconData get location => Icons.location_on_outlined;
  static IconData get note => Icons.notes_outlined;
  static IconData get attachment => Icons.attach_file_outlined;

  // Status
  static IconData get check => Icons.check_circle_outlined;
  static IconData get error => Icons.error_outline;
  static IconData get warning => Icons.warning_amber_rounded;
  static IconData get info => Icons.info_outlined;
  static IconData get pending => Icons.schedule_outlined;

  /// Returns an icon for a given [LedgerEntryType] name.
  static IconData forLedgerType(String type) => switch (type) {
    'give' || 'borrow' => give,
    'receive' || 'repayment' => receive,
    'sale' => sale,
    'purchase' => purchase,
    'discount' => discount,
    'adjustment' => adjustment,
    'opening' => Icons.flag_outlined,
    'manual' => Icons.edit_outlined,
    _ => ledger,
  };

  /// Returns a color for a given transactional direction.
  static Color colorForLedgerType(String type) => switch (type) {
    'give' || 'borrow' => DesignTokens.expense,
    'receive' || 'repayment' => DesignTokens.income,
    'sale' => Colors.blue,
    'purchase' => Colors.orange,
    'discount' => Colors.purple,
    'adjustment' => Colors.teal,
    _ => DesignTokens.neutral,
  };
}
