import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/payment_method/domain/entities/payment_method.dart';
import 'package:paysa/features/payment_method/domain/entities/payment_method_defaults.dart';
import 'package:paysa/features/payment_method/domain/entities/payment_method_type.dart';

final _now = DateTime.now();

void main() {
  group('PaymentMethod', () {
    test('default values', () {
      final m = PaymentMethod(name: 'Cash', createdAt: _now, updatedAt: _now);
      expect(m.isBuiltIn, false);
      expect(m.isEnabled, true);
      expect(m.isFavorite, false);
      expect(m.id, 0);
    });

    test('isActive when enabled and not deleted', () {
      final m = PaymentMethod(name: 'X', createdAt: _now, updatedAt: _now);
      expect(m.isActive, true);
    });

    test('isDeleted when deletedAt is set', () {
      final m = PaymentMethod(name: 'X', createdAt: _now, updatedAt: _now, deletedAt: _now);
      expect(m.isDeleted, true);
      expect(m.isActive, false);
    });

    test('validation: empty name', () {
      final m = PaymentMethod(name: '', createdAt: _now, updatedAt: _now);
      expect(m.validate(), isNotNull);
    });

    test('validation: name over 50 chars', () {
      final m = PaymentMethod(name: 'A' * 51, createdAt: _now, updatedAt: _now);
      expect(m.validate(), isNotNull);
    });

    test('validation: valid name passes', () {
      final m = PaymentMethod(name: 'bKash', createdAt: _now, updatedAt: _now);
      expect(m.validate(), isNull);
    });

    test('copyWith preserves type', () {
      final m = PaymentMethod(name: 'A', type: PaymentMethodType.bkash, createdAt: _now, updatedAt: _now);
      final c = m.copyWith(name: 'B');
      expect(c.type, PaymentMethodType.bkash);
    });
  });

  group('PaymentMethodType', () {
    test('all 11 types have labels', () {
      expect(PaymentMethodType.values.length, 11);
      for (final t in PaymentMethodType.values) {
        expect(t.label.isNotEmpty, true);
        expect(t.iconKey.isNotEmpty, true);
      }
    });

    test('mobile wallet detection', () {
      expect(PaymentMethodType.bkash.isMobileWallet, true);
      expect(PaymentMethodType.nagad.isMobileWallet, true);
      expect(PaymentMethodType.rocket.isMobileWallet, true);
      expect(PaymentMethodType.upay.isMobileWallet, true);
      expect(PaymentMethodType.cash.isMobileWallet, false);
      expect(PaymentMethodType.bankAccount.isMobileWallet, false);
    });
  });

  group('PaymentMethodDefaults', () {
    test('systemPresets returns 11 methods', () {
      final presets = PaymentMethodDefaults.systemPresets(_now);
      expect(presets.length, 11);
      for (final p in presets) {
        expect(p.isBuiltIn, true);
      }
    });

    test('first preset is Cash', () {
      final presets = PaymentMethodDefaults.systemPresets(_now);
      expect(presets.first.name, 'Cash');
      expect(presets.first.type, PaymentMethodType.cash);
    });
  });

  group('PaymentCapability', () {
    test('defaults are false', () {
      final c = PaymentCapability();
      expect(c.supportsPaymentLink, false);
      expect(c.supportsQRCode, false);
      expect(c.supportsPartialPayment, false);
      expect(c.supportsRefund, false);
    });

    test('bKash has all capabilities', () {
      final presets = PaymentMethodDefaults.systemPresets(_now);
      final bkash = presets.firstWhere((p) => p.type == PaymentMethodType.bkash);
      expect(bkash.capabilities.supportsPaymentLink, true);
      expect(bkash.capabilities.supportsQRCode, true);
      expect(bkash.capabilities.supportsPartialPayment, true);
      expect(bkash.capabilities.supportsRefund, true);
    });
  });
}
