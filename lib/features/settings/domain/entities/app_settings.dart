// ---------------------------------------------------------------------------
// Theme Mode
// ---------------------------------------------------------------------------

enum ThemeModePreference { system, light, dark }

// ---------------------------------------------------------------------------
// Currency & Locale
// ---------------------------------------------------------------------------

final class CurrencyConfig {
  const CurrencyConfig({
    this.code = 'USD',
    this.symbol = r'$',
    this.decimalPlaces = 2,
    this.decimalSeparator = '.',
    this.thousandsSeparator = ',',
  });

  final String code;
  final String symbol;
  final int decimalPlaces;
  final String decimalSeparator;
  final String thousandsSeparator;

  String format(int amountMinor) {
    final value = (amountMinor / 100).toStringAsFixed(decimalPlaces);
    final parts = value.split('.');
    parts[0] = parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}$thousandsSeparator');
    return '$symbol${parts.join(decimalSeparator)}';
  }
}

// ---------------------------------------------------------------------------
// Date & Time
// ---------------------------------------------------------------------------

enum DateFormatStyle { dmy, mdy, ymd }
enum FirstDayOfWeek { sunday, monday, saturday }
enum DefaultReportRange { thisMonth, lastMonth, last3Months, thisYear }

// ---------------------------------------------------------------------------
// Privacy
// ---------------------------------------------------------------------------

enum AutoLockTimeout { immediate, oneMinute, fiveMinutes, fifteenMinutes }

// ---------------------------------------------------------------------------
// Notification Preferences
// ---------------------------------------------------------------------------

final class NotificationPreferences {
  const NotificationPreferences({
    this.paymentReminders = true,
    this.ledgerReminders = true,
    this.budgetReminders = true,
    this.dailySummary = false,
  });

  final bool paymentReminders;
  final bool ledgerReminders;
  final bool budgetReminders;
  final bool dailySummary;

  NotificationPreferences copyWith({
    bool? paymentReminders, bool? ledgerReminders,
    bool? budgetReminders, bool? dailySummary,
  }) => NotificationPreferences(
    paymentReminders: paymentReminders ?? this.paymentReminders,
    ledgerReminders: ledgerReminders ?? this.ledgerReminders,
    budgetReminders: budgetReminders ?? this.budgetReminders,
    dailySummary: dailySummary ?? this.dailySummary,
  );
}

// ---------------------------------------------------------------------------
// Accessibility
// ---------------------------------------------------------------------------

final class AccessibilityPreferences {
  const AccessibilityPreferences({
    this.largeText = false,
    this.reducedMotion = false,
    this.highContrast = false,
  });

  final bool largeText;
  final bool reducedMotion;
  final bool highContrast;

  AccessibilityPreferences copyWith({
    bool? largeText, bool? reducedMotion, bool? highContrast,
  }) => AccessibilityPreferences(
    largeText: largeText ?? this.largeText,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    highContrast: highContrast ?? this.highContrast,
  );
}

// ---------------------------------------------------------------------------
// App Settings — aggregate root
// ---------------------------------------------------------------------------

final class AppSettings {
  const AppSettings({
    this.themeMode = ThemeModePreference.system,
    this.currency = const CurrencyConfig(),
    this.dateFormat = DateFormatStyle.dmy,
    this.firstDayOfWeek = FirstDayOfWeek.monday,
    this.defaultReportRange = DefaultReportRange.thisMonth,
    this.hideBalance = false,
    this.appLockEnabled = false,
    this.autoLockTimeout = AutoLockTimeout.fiveMinutes,
    this.notifications = const NotificationPreferences(),
    this.accessibility = const AccessibilityPreferences(),
    this.version = 1,
  });

  final ThemeModePreference themeMode;
  final CurrencyConfig currency;
  final DateFormatStyle dateFormat;
  final FirstDayOfWeek firstDayOfWeek;
  final DefaultReportRange defaultReportRange;
  final bool hideBalance;
  final bool appLockEnabled;
  final AutoLockTimeout autoLockTimeout;
  final NotificationPreferences notifications;
  final AccessibilityPreferences accessibility;
  final int version;

  AppSettings copyWith({
    ThemeModePreference? themeMode, CurrencyConfig? currency,
    DateFormatStyle? dateFormat, FirstDayOfWeek? firstDayOfWeek,
    DefaultReportRange? defaultReportRange,
    bool? hideBalance, bool? appLockEnabled, AutoLockTimeout? autoLockTimeout,
    NotificationPreferences? notifications, AccessibilityPreferences? accessibility,
    int? version,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode, currency: currency ?? this.currency,
    dateFormat: dateFormat ?? this.dateFormat,
    firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    defaultReportRange: defaultReportRange ?? this.defaultReportRange,
    hideBalance: hideBalance ?? this.hideBalance,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
    notifications: notifications ?? this.notifications,
    accessibility: accessibility ?? this.accessibility,
    version: version ?? this.version,
  );
}
