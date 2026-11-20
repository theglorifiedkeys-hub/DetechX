import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/lucide_icons.dart';
import '../../app/theme.dart';
import '../../core/surfaces.dart';
import '../service_data.dart';
import '../payments/service_checkout.dart';
import 'dotted_map.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({
    super.key,
    required this.result,
    this.neighborhood = '',
  });
  final DiagnosticResult result;
  final String neighborhood;
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  static const _tech = MockServiceRepository.technician;
  late final _route = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _trip = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 48),
  );
  late final _sheet = AnimationController.unbounded(vsync: this);
  bool _animated = false;
  late final ServiceCheckout _checkout;

  @override
  void initState() {
    super.initState();
    _checkout = ServiceCheckout(
      ServiceInvoice(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        amountTzs: widget.result.low,
        description: widget.result.service,
      ),
      const SimulatedPaymentGateway(),
    )..addListener(_onStageChange);
    _trip.addStatusListener(_onTripStatus);
  }

  void _onTripStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _checkout.stage == ServiceStage.enRoute) {
      _checkout.advance();
    }
  }

  void _onStageChange() {
    if (_checkout.stage != ServiceStage.enRoute && !_trip.isCompleted) {
      _trip.value = 1;
    }
    setState(() {});
  }

  Future<void> _reviewInvoice() async {
    final invoice = _checkout.invoice;
    final confirmed = await showPanel<bool>(context, 'Review invoice', [
      Text(invoice.description, style: AppTypography.label),
      const SizedBox(height: 6),
      Text(
        formatTzs(invoice.amountTzs),
        style: AppTypography.title.merge(AppTypography.number),
      ),
      const SizedBox(height: 12),
      const Text(
        'This is a test invoice. Confirming will not send a mobile-money prompt or charge you.',
      ),
      const SizedBox(height: 16),
      PillButton('Confirm test payment', () => Navigator.pop(context, true)),
    ]);
    if (mounted && confirmed == true) await _checkout.pay();
  }

  void _showReceipt() {
    final receipt = _checkout.receipt!;
    showPanel<void>(context, 'Test receipt', [
      Text(_checkout.invoice.description, style: AppTypography.label),
      const SizedBox(height: 6),
      Text(
        formatTzs(receipt.amountTzs),
        style: AppTypography.title.merge(AppTypography.number),
      ),
      const SizedBox(height: 6),
      Text('Reference: ${receipt.reference}', style: AppTypography.caption),
      const SizedBox(height: 6),
      const Text('No money was collected.'),
    ]);
  }

  Widget _serviceProgress() {
    final (
      String title,
      String detail,
      String action,
      VoidCallback? callback,
    ) = switch (_checkout.stage) {
      ServiceStage.enRoute => (
        'Fundi yuko njiani',
        'Track your technician’s arrival.',
        'Confirm arrival',
        _checkout.advance,
      ),
      ServiceStage.arrived => (
        'Fundi amefika',
        'Start the service when you’re ready.',
        'Start work',
        _checkout.advance,
      ),
      ServiceStage.working => (
        'Kazi inaendelea',
        'Confirm completion only after checking the work.',
        'Confirm work complete',
        _checkout.advance,
      ),
      ServiceStage.invoiceReady => (
        'Kazi imekamilika',
        _checkout.paymentFailed
            ? 'Test payment failed. You can try again.'
            : 'Review the final test invoice before paying.',
        'Review & pay',
        _reviewInvoice,
      ),
      ServiceStage.paymentPending => (
        'Malipo yanasubiri',
        'Confirming your test payment…',
        '',
        null,
      ),
      ServiceStage.paid => (
        'Malipo yamekamilika',
        'Test payment complete · no money collected.',
        'View receipt',
        _showReceipt,
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GlassSurface(
        radius: 20,
        shadow: false,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 210),
              child: Column(
                key: ValueKey(_checkout.stage),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: AppTypography.label),
                  const SizedBox(height: 3),
                  Text(detail, style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(height: 7),
            if (callback != null)
              PillButton(action, callback, height: 40)
            else
              const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _route.value = 1;
      _trip.stop();
    }
    if (!reduce && !_animated) {
      _animated = true;
      _route.forward();
      _trip.forward();
    }
    if (!reduce && _animated && !_trip.isCompleted && !_trip.isAnimating) {
      _trip.forward();
    }
  }

  @override
  void dispose() {
    _checkout.dispose();
    _route.dispose();
    _trip.dispose();
    _sheet.dispose();
    super.dispose();
  }

  void _settle(double target, [double velocity = 0]) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _sheet.value = target;
    } else {
      _sheet.animateWith(
        SpringSimulation(spring, _sheet.value, target, velocity),
      );
    }
  }

  void _toggle() => _settle(_sheet.value > .45 ? 0 : 1);
  void _call() => showPanel<void>(context, 'Call ${_tech.name}', [
    const Text('This is a simulated dispatch. No phone call will be placed.'),
    const SizedBox(height: 15),
    PillButton('Done', () => Navigator.pop(context)),
  ]);
  void _message() =>
      showPanel<void>(context, 'Message ${_tech.name}', [const _DemoMessage()]);
  void _options() => showPanel<void>(context, 'Trip options', [
    const ListTile(
      leading: Icon(LucideIcons.radio),
      title: Text('Simulated dispatch'),
      subtitle: Text('Route and arrival times are illustrative.'),
    ),
    ListTile(
      leading: const Icon(LucideIcons.clipboardList),
      title: const Text('Service details'),
      onTap: () {
        Navigator.pop(context);
        showScope(context, widget.result.service, widget.result.estimate);
      },
    ),
  ]);

  Widget _profile() => Row(
    children: [
      const CircleAvatar(
        radius: 23,
        backgroundImage: AssetImage('assets/mike.jpg'),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_tech.name, style: AppTypography.label),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.starGold,
                  size: 15,
                ),
                Text(
                  _tech.rating,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: AppTypography.numberFeatures,
                  ),
                ),
                Text(
                  '${_tech.specialty} · ${_tech.jobs} services',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
        ),
      ),
      RoundAction(
        LucideIcons.chevronsUpDown,
        'Toggle technician details',
        _toggle,
        size: 36,
        dark: true,
      ),
    ],
  );

  Widget _bottomSheet(double maxHeight) => GlassSurface(
    radius: 30,
    blur: true,
    padding: const EdgeInsets.fromLTRB(11, 4, 11, 10),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              onVerticalDragUpdate: (details) {
                _sheet.stop();
                _sheet.value = (_sheet.value - details.delta.dy / 75)
                    .clamp(0.0, 1.0)
                    .toDouble();
              },
              onVerticalDragEnd: (details) {
                final speed = -(details.primaryVelocity ?? 0) / 75;
                _settle(
                  speed.abs() > 2
                      ? (speed > 0 ? 1 : 0)
                      : (_sheet.value > .5 ? 1 : 0),
                  speed,
                );
              },
              child: SizedBox(
                height: 17,
                width: double.infinity,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xffcfc3bc),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
            _profile(),
            AnimatedBuilder(
              animation: _sheet,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ListTile(
                  dense: true,
                  leading: Icon(LucideIcons.badgeCheck),
                  title: Text('Background checked · HVAC certified'),
                  subtitle: Text('White service van · ${_tech.plate}'),
                ),
              ),
              builder: (_, child) => ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _sheet.value.clamp(0.0, 1.0).toDouble(),
                  child: child,
                ),
              ),
            ),
            const SizedBox(height: 9),
            GlassSurface(
              radius: 19,
              shadow: false,
              padding: const EdgeInsets.all(7),
              child: Row(
                children: [
                  acPhoto(49),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.result.service,
                          style: AppTypography.label.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated ${widget.result.estimate}',
                          style: AppTypography.caption.merge(
                            AppTypography.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PillButton(
                    'View',
                    () => showScope(
                      context,
                      widget.result.service,
                      widget.result.estimate,
                    ),
                    dark: false,
                    height: 35,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    'Call',
                    _call,
                    icon: LucideIcons.phone,
                    dark: false,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PillButton(
                    'Message',
                    _message,
                    icon: LucideIcons.messageCircle,
                    dark: false,
                    height: 44,
                  ),
                ),
              ],
            ),
            _serviceProgress(),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, limits) {
        final sheetBudget = (limits.maxHeight * .68)
            .clamp(0.0, 350.0)
            .toDouble();
        return Stack(
          children: [
            const AmbientCoralBackdrop(center: Alignment(.36, .33)),
            Positioned.fill(
              bottom: 150,
              child: DottedVectorMapCanvas(route: _route, trip: _trip),
            ),
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    FlowHeader(
                      'Your Technician',
                      onOptions: _options,
                      blur: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.neighborhood.isEmpty ? 'DAR ES SALAAM' : widget.neighborhood.toUpperCase()}  /  SIMULATED ROUTE',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (limits.maxHeight > 410 &&
                _checkout.stage == ServiceStage.enRoute)
              Positioned(
                top: (limits.maxHeight - 150) * .39 + 12,
                right: limits.maxWidth * .10,
                child: AnimatedBuilder(
                  animation: _trip,
                  builder: (_, _) {
                    final minutes = (12 * (1 - _trip.value)).ceil();
                    return GlassSurface(
                      blur: true,
                      radius: 999,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.clock3,
                            size: 15,
                            color: AppColors.auraCoralDeep,
                          ),
                          const SizedBox(width: 7),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Arriving',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                              Text(
                                minutes == 0 ? 'Arrived' : '$minutes min',
                                style: AppTypography.label.merge(
                                  AppTypography.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: SafeArea(
                top: false,
                child: Reveal(delay: 110, child: _bottomSheet(sheetBudget)),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _DemoMessage extends StatefulWidget {
  const _DemoMessage();
  @override
  State<_DemoMessage> createState() => _DemoMessageState();
}

class _DemoMessageState extends State<_DemoMessage> {
  final _text = TextEditingController();
  bool _sent = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _sent
      ? const Text(
          'Message saved for this demo. Nothing was sent to a real technician.',
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _text,
              decoration: const InputDecoration(hintText: 'Write a message…'),
            ),
            const SizedBox(height: 12),
            PillButton('Send demo message', () {
              if (_text.text.trim().isNotEmpty) setState(() => _sent = true);
            }),
          ],
        );
}
