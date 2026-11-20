import 'dart:async';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../admin/admin_screen.dart';
import '../admin/demo_access.dart';
import '../admin/dispatch_store.dart';
import '../location/dar_location.dart';
import '../tracking/map_lab.dart';
import '../../app/preferences.dart';
import 'profile_editor.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/lucide_icons.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/surfaces.dart';
import '../assistant/assistant_screen.dart';
import '../service_data.dart';

const _categories = [
  (name: 'HVAC', icon: LucideIcons.snowflake, prompt: initialIssue),
  (
    name: 'Plumbing',
    icon: LucideIcons.droplets,
    prompt: 'My kitchen sink is draining slowly.',
  ),
  (
    name: 'Electrical',
    icon: LucideIcons.zap,
    prompt: 'An electrical outlet stopped working.',
  ),
  (
    name: 'Appliances',
    icon: LucideIcons.washingMachine,
    prompt: 'My appliance is making a strange noise.',
  ),
  (
    name: 'Handyman',
    icon: LucideIcons.hammer,
    prompt: 'I need help with a home maintenance repair.',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.settings});
  final AppPreferences settings;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _prompt = TextEditingController();
  AppPreferences get _settings => widget.settings;
  String get _address =>
      _settings.neighborhood.isEmpty ? 'Dar es Salaam' : _settings.neighborhood;
  String get _initial => _settings.name.isEmpty
      ? '•'
      : _settings.name.characters.first.toUpperCase();
  DateTime _time = darTime(DateTime.now());
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_refresh);
    _clock = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() => _time = darTime(DateTime.now())),
    );
  }

  void _refresh() => setState(() {});

  Future<void> _save(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your settings. Please try again.'),
          ),
        );
      }
    }
  }

  void _editProfile() =>
      showPanel<void>(context, 'Edit profile', [ProfileEditor(_settings)]);

  void _openSettings() => showPanel<void>(context, 'Mipangilio', [
    ListenableBuilder(
      listenable: _settings,
      builder: (_, _) => SwitchListTile(
        title: const Text('Reduce motion'),
        subtitle: const Text('Limit transitions and route animation'),
        value: _settings.reduceMotion,
        onChanged: (value) => _save(() => _settings.saveMotion(value)),
      ),
    ),
    const ListTile(
      title: Text('Region and currency'),
      subtitle: Text('Dar es Salaam, Tanzania · TZS'),
    ),
    const ListTile(
      title: Text('About this build'),
      subtitle: Text(
        'Profile and settings stay on this device. Estimates and technician dispatch are simulated.',
      ),
    ),
  ]);
  XFile? _attachment;
  int _tab = 0;
  DemoRole? _role;
  final _dispatch = DemoDispatchStore();

  Future<void> _login() async {
    final role = await chooseDemoRole(context);
    if (!mounted || role == null) return;
    setState(() => _role = role);
    if (role != DemoRole.customer) _openWorkspace();
  }

  void _openWorkspace() {
    final role = _role;
    if (role == null || role == DemoRole.customer) return;
    openFlow(
      context,
      AdminScreen(
        store: _dispatch,
        technician: role == DemoRole.technician
            ? DemoDispatchStore.technicians.first
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    _dispatch.dispose();
    _settings.removeListener(_refresh);
    _prompt.dispose();
    super.dispose();
  }

  void _openAi([String? prompt]) {
    FocusScope.of(context).unfocus();
    final issue = (prompt ?? _prompt.text).trim();
    openFlow(
      context,
      AssistantScreen(
        issue: issue,
        neighborhood: _settings.neighborhood,
        attachment: prompt == null ? _attachment?.name : null,
      ),
    );
  }

  Future<void> _chooseAddress() async {
    var locating = false;
    String? hint, suggested;
    final address = await showPanel<String>(context, 'Chagua eneo la huduma', [
      StatefulBuilder(
        builder: (sheet, update) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'GPS inapendekeza mtaa wa karibu. Thibitisha au chagua mwenyewe; anwani kamili haijahifadhiwa.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 8),
            PillButton(
              locating ? 'Inatafuta eneo…' : 'Tambua eneo langu',
              () async {
                if (locating) return;
                update(() {
                  locating = true;
                  hint = null;
                  suggested = null;
                });
                try {
                  final position = await readDevicePosition();
                  if (!sheet.mounted) return;
                  update(() {
                    suggested = suggestDarArea(
                      LatLng(position.latitude, position.longitude),
                      position.accuracy,
                    );
                    if (suggested == null)
                      hint =
                          'GPS haijapata mtaa wa huduma kwa uhakika. Tafadhali chagua mwenyewe.';
                  });
                } catch (error) {
                  if (sheet.mounted)
                    update(
                      () => hint = error is LocationProblem
                          ? error.message
                          : 'Hatukuweza kupata eneo. Chagua mtaa mwenyewe.',
                    );
                } finally {
                  if (sheet.mounted) update(() => locating = false);
                }
              },
              icon: Icons.my_location,
              height: 42,
            ),
            if (hint case final message?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(message, style: AppTypography.caption),
              ),
            if (suggested case final area?)
              ListTile(
                title: Text('Pendekezo: $area'),
                subtitle: const Text('Gusa kuthibitisha eneo'),
                trailing: const Icon(Icons.check),
                onTap: () => Navigator.pop(sheet, area),
              ),
          ],
        ),
      ),
      for (final area in darAreas.keys)
        ListTile(
          leading: const Icon(LucideIcons.mapPin),
          title: Text(area),
          trailing: area == _address ? const Icon(LucideIcons.check) : null,
          onTap: () => Navigator.pop(context, area),
        ),
    ]);
    if (mounted && address != null) {
      await _save(() => _settings.saveNeighborhood(address));
    }
  }

  Future<void> _attach() async {
    final result = await pickAttachment(context);
    if (mounted && result != null) setState(() => _attachment = result);
  }

  Widget _section(String title, {String? action, VoidCallback? onTap}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: AppTypography.title.copyWith(fontSize: 17)),
      if (action != null)
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.inkSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );

  Widget _bookingsEmpty() => GlassSurface(
    radius: 24,
    padding: const EdgeInsets.all(15),
    child: Row(
      children: [
        const Icon(LucideIcons.calendarDays, color: AppColors.auraCoralDeep),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hakuna miadi inayokuja', style: AppTypography.label),
              SizedBox(height: 3),
              Text(
                'Start with a service to explore your options.',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        if (_tab == 2)
          PillButton(
            'Services',
            () => setState(() => _tab = 1),
            dark: false,
            height: 36,
          ),
      ],
    ),
  );

  Widget _hero() => GlassSurface(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.badgePeachBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 18,
                color: AppColors.auraCoralDeep,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What's wrong?", style: AppTypography.title),
                  SizedBox(height: 3),
                  Text(
                    "Tell us what's happening and AI will help",
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        GlassSurface(
          radius: 19,
          shadow: false,
          padding: const EdgeInsets.fromLTRB(10, 3, 8, 7),
          child: Column(
            children: [
              TextField(
                controller: _prompt,
                minLines: 2,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: "My AC is running but isn't cooling...",
                  contentPadding: EdgeInsets.all(5),
                ),
              ),
              Row(
                children: [
                  RoundAction(
                    LucideIcons.plus,
                    'Attach a photo or video',
                    _attach,
                    size: 32,
                  ),
                  if (_attachment != null)
                    Expanded(
                      child: Text(
                        _attachment!.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption,
                      ),
                    )
                  else
                    const Spacer(),
                  PillButton(
                    'Ask with AI',
                    _openAi,
                    icon: LucideIcons.sparkles,
                    dark: false,
                    height: 32,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            'Describe Your Problem',
            _openAi,
            trailing: LucideIcons.arrowUpRight,
          ),
        ),
      ],
    ),
  );

  Widget _services() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    clipBehavior: Clip.none,
    child: Row(
      children: [
        for (final (index, item) in _categories.indexed)
          Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Reveal(
              delay: 135 + index * 40,
              child: PillButton(
                item.name,
                () => _openAi(item.prompt),
                icon: item.icon,
                height: 44,
                dark: false,
              ),
            ),
          ),
      ],
    ),
  );

  List<Widget> _page() => switch (_tab) {
    0 => [
      Reveal(
        delay: 45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('EEE, d MMM y').format(_time)} · EAT',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 7),
            Text(
              '${darGreeting(_time.hour)}${_settings.name.isEmpty ? '' : ',\n${_settings.name}'}',
              style: const TextStyle(
                fontSize: 28,
                height: 1.12,
                letterSpacing: -.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Reveal(delay: 90, child: _hero()),
      const SizedBox(height: 12),
      _section(
        'Quick Services',
        action: 'See all',
        onTap: () => setState(() => _tab = 1),
      ),
      _services(),
      const SizedBox(height: 14),
      const SizedBox(height: 20),
      Reveal(
        delay: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Huduma zinazokuja'),
            const SizedBox(height: 9),
            _bookingsEmpty(),
          ],
        ),
      ),
    ],
    1 => [
      const Text('Explore services', style: AppTypography.title),
      const SizedBox(height: 12),
      for (final item in _categories)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: GlassSurface(
            radius: 20,
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(item.name),
              trailing: const Icon(LucideIcons.arrowUpRight, size: 18),
              onTap: () => _openAi(item.prompt),
            ),
          ),
        ),
    ],
    2 => [
      _section('Your bookings'),
      const SizedBox(height: 12),
      _bookingsEmpty(),
    ],
    _ => [
      const Text('Wasifu wako', style: AppTypography.title),
      const SizedBox(height: 12),
      GlassSurface(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(child: Text(_initial)),
              title: Text(
                _settings.name.isEmpty ? 'Set up your profile' : _settings.name,
              ),
              subtitle: Text(
                _settings.phone.isEmpty
                    ? 'Edit name and contact details'
                    : _settings.phone,
              ),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: _editProfile,
            ),
            ListTile(
              leading: const Icon(LucideIcons.mapPin),
              title: Text(_address),
              subtitle: const Text('Service neighborhood'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: _chooseAddress,
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(
                _role == null
                    ? 'Ingia'
                    : 'Akaunti ya majaribio · ${_role!.label}',
              ),
              subtitle: const Text('Mteja, fundi au msimamizi'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: _login,
            ),
            if (_role == DemoRole.technician || _role == DemoRole.dispatcher)
              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Fungua eneo la kazi'),
                onTap: _openWorkspace,
              ),
            if (_role != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Toka'),
                onTap: () => setState(() => _role = null),
              ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Ramani ya Dar es Salaam'),
              onTap: () => openFlow(
                context,
                MapLab(neighborhood: _settings.neighborhood),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.wrench),
              title: const Text('Mipangilio'),
              subtitle: const Text('Motion, region and app information'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: _openSettings,
            ),
          ],
        ),
      ),
    ],
  };

  Widget _dock() {
    const tabs = [
      (LucideIcons.house, 'Mwanzo'),
      (LucideIcons.wrench, 'Huduma'),
      (LucideIcons.calendarDays, 'Miadi'),
      (LucideIcons.userRound, 'Wasifu'),
    ];
    return Row(
      children: [
        Expanded(
          child: GlassSurface(
            radius: 99,
            blur: true,
            padding: const EdgeInsets.all(5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final unit = constraints.maxWidth / 5;
                final duration = MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300);
                return SizedBox(
                  height: 44,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: duration,
                        curve: motionCurve,
                        left: unit * _tab,
                        width: unit * 2,
                        top: 0,
                        bottom: 0,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.badgePeachBg,
                            borderRadius: BorderRadius.all(Radius.circular(99)),
                          ),
                        ),
                      ),
                      for (final (index, tab) in tabs.indexed)
                        AnimatedPositioned(
                          key: ValueKey(index),
                          duration: duration,
                          curve: motionCurve,
                          left: unit * (index + (index > _tab ? 1 : 0)),
                          width: unit * (index == _tab ? 2 : 1),
                          top: 0,
                          bottom: 0,
                          child: SpringScaleTap(
                            label: tab.$2,
                            selected: index == _tab,
                            onTap: () => setState(() => _tab = index),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(tab.$1, size: 18),
                                if (index == _tab)
                                  Flexible(
                                    child: Reveal(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          tab.$2,
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 9),
        RepaintBoundary(
          child: SpringScaleTap(
            label: 'Open AI Assistant',
            onTap: _openAi,
            child: Hero(
              tag: 'ai-orb',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  gradient: const RadialGradient(
                    center: Alignment(-.4, -.55),
                    colors: [
                      Color(0xffffeee4),
                      Color(0xfff9b49c),
                      Color(0xffec8566),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40df7756),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.sparkles, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: _tab == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _tab != 0) setState(() => _tab = 0);
    },
    child: Scaffold(
      body: Stack(
        children: [
          const AmbientCoralBackdrop(center: Alignment(.5, -.02)),
          SafeArea(
            child: CustomScrollView(
              key: PageStorageKey(_tab),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 94),
                  sliver: SliverList.list(
                    children: [
                      Reveal(
                        child: Row(
                          children: [
                            RoundAction(
                              LucideIcons.mapPin,
                              'Change location',
                              _chooseAddress,
                              size: 42,
                            ),
                            const SizedBox(width: 6),
                            PillButton(
                              _address,
                              _chooseAddress,
                              dark: false,
                              height: 42,
                              trailing: LucideIcons.chevronDown,
                            ),
                            const Spacer(),
                            SpringScaleTap(
                              label: 'Open profile',
                              onTap: () => setState(() => _tab = 3),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xffeac3af),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _initial,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 19),
                      ..._page(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.viewInsetsOf(context).bottom == 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 13,
              child: SafeArea(
                top: false,
                child: Reveal(delay: 220, child: _dock()),
              ),
            ),
        ],
      ),
    ),
  );
}
