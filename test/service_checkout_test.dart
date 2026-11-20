import 'dart:async';
import 'package:detechx/features/payments/service_checkout.dart';
import 'package:flutter_test/flutter_test.dart';

const invoice = ServiceInvoice(
  id: 'visit-1',
  amountTzs: 45000,
  description: 'AC inspection',
);
const matchingReceipt = PaymentReceipt(
  invoiceId: 'visit-1',
  reference: 'TEST-1',
  amountTzs: 45000,
);

class ControlledGateway implements PaymentGateway {
  int requests = 0;
  Completer<PaymentReceipt> result = Completer<PaymentReceipt>();
  @override
  Future<PaymentReceipt> pay(ServiceInvoice invoice) {
    requests++;
    return result.future;
  }
}

void main() {
  test('payment requires completion and cannot be started twice', () async {
    final gateway = ControlledGateway();
    final checkout = ServiceCheckout(invoice, gateway);
    addTearDown(checkout.dispose);
    await checkout.pay();
    expect(gateway.requests, 0);
    for (final stage in [
      ServiceStage.arrived,
      ServiceStage.working,
      ServiceStage.invoiceReady,
    ]) {
      checkout.advance();
      expect(checkout.stage, stage);
    }
    final paying = checkout.pay();
    expect(checkout.stage, ServiceStage.paymentPending);
    await checkout.pay();
    expect(gateway.requests, 1);
    gateway.result.complete(matchingReceipt);
    await paying;
    expect(checkout.stage, ServiceStage.paid);
    expect(checkout.receipt, matchingReceipt);
  });

  test(
    'a mismatched receipt never settles the invoice; test payment can retry',
    () async {
      final gateway = ControlledGateway();
      final checkout = ServiceCheckout(invoice, gateway);
      addTearDown(checkout.dispose);
      checkout
        ..advance()
        ..advance()
        ..advance();
      final first = checkout.pay();
      gateway.result.complete(
        const PaymentReceipt(
          invoiceId: 'different',
          reference: 'TEST-2',
          amountTzs: 45000,
        ),
      );
      await first;
      expect(checkout.stage, ServiceStage.invoiceReady);
      expect(checkout.paymentFailed, isTrue);
      expect(checkout.receipt, isNull);
      gateway.result = Completer<PaymentReceipt>();
      final retry = checkout.pay();
      gateway.result.complete(matchingReceipt);
      await retry;
      expect(checkout.stage, ServiceStage.paid);
      expect(checkout.paymentFailed, isFalse);
    },
  );
}
