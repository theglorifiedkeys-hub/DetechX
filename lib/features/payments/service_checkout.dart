import 'package:flutter/foundation.dart';

/// These events are local for the prototype. In production, only the backend
/// should authorize technician milestones and settle invoices.
enum ServiceStage {
  enRoute,
  arrived,
  working,
  invoiceReady,
  paymentPending,
  paid,
}

@immutable
class ServiceInvoice {
  const ServiceInvoice({
    required this.id,
    required this.amountTzs,
    required this.description,
  });
  final String id, description;
  final int amountTzs;
}

@immutable
class PaymentReceipt {
  const PaymentReceipt({
    required this.invoiceId,
    required this.reference,
    required this.amountTzs,
  });
  final String invoiceId, reference;
  final int amountTzs;
}

abstract interface class PaymentGateway {
  Future<PaymentReceipt> pay(ServiceInvoice invoice);
}

class SimulatedPaymentGateway implements PaymentGateway {
  const SimulatedPaymentGateway();
  @override
  Future<PaymentReceipt> pay(ServiceInvoice invoice) async {
    await Future<void>.delayed(const Duration(milliseconds: 950));
    return PaymentReceipt(
      invoiceId: invoice.id,
      reference: 'TEST-${invoice.id}',
      amountTzs: invoice.amountTzs,
    );
  }
}

class ServiceCheckout extends ChangeNotifier {
  ServiceCheckout(this.invoice, this._gateway);
  final ServiceInvoice invoice;
  final PaymentGateway _gateway;
  ServiceStage _stage = ServiceStage.enRoute;
  ServiceStage get stage => _stage;
  PaymentReceipt? _receipt;
  PaymentReceipt? get receipt => _receipt;
  bool _paymentFailed = false;
  bool get paymentFailed => _paymentFailed;
  bool _disposed = false;

  void _transition(ServiceStage next) {
    _stage = next;
    notifyListeners();
  }

  void advance() {
    final next = switch (_stage) {
      ServiceStage.enRoute => ServiceStage.arrived,
      ServiceStage.arrived => ServiceStage.working,
      ServiceStage.working => ServiceStage.invoiceReady,
      _ => null,
    };
    if (next != null) _transition(next);
  }

  Future<void> pay() async {
    if (_stage != ServiceStage.invoiceReady) return;
    _paymentFailed = false;
    _transition(ServiceStage.paymentPending);
    try {
      final receipt = await _gateway.pay(invoice);
      if (_disposed) return;
      if (receipt.invoiceId != invoice.id ||
          receipt.amountTzs != invoice.amountTzs ||
          receipt.reference.isEmpty) {
        throw StateError('Receipt does not match invoice');
      }
      _receipt = receipt;
      _transition(ServiceStage.paid);
    } catch (_) {
      if (_disposed) return;
      _paymentFailed = true;
      _transition(ServiceStage.invoiceReady);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
