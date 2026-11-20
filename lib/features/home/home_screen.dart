import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/lucide_icons.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/surfaces.dart';
import '../assistant/assistant_screen.dart';
import '../service_data.dart';
import '../tracking/tracking_screen.dart';

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
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _prompt = TextEditingController();
  String _address = MockServiceRepository.addresses.first;
  XFile? _attachment;
  int _tab = 0;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  void _openAi([String? prompt]) {
    FocusScope.of(context).unfocus();
    final issue = (prompt ?? _prompt.text).trim();
    openFlow(
      context,
      AssistantScreen(
        issue: issue.isEmpty ? initialIssue : issue,
        attachment: prompt == null ? _attachment?.name : null,
      ),
    );
  }

  Future<void> _chooseAddress() async {
    final address = await showPanel<String>(context, 'Service address', [
      for (final address in MockServiceRepository.addresses)
        ListTile(
          leading: const Icon(LucideIcons.mapPin),
          title: Text(address),
          trailing: address == _address ? const Icon(LucideIcons.check) : null,
          onTap: () => Navigator.pop(context, address),
        ),
    ]);
    if (mounted && address != null) setState(() => _address = address);
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

  Widget _booking() => GlassSurface(
    radius: 24,
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        acPhoto(76),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.badgePeachBg,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Tomorrow 10:00 AM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFeatures: AppTypography.numberFeatures,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text('AC Maintenance', style: AppTypography.label),
              SizedBox(height: 3),
              Text('With Mike Richardson', style: AppTypography.caption),
            ],
          ),
        ),
        PillButton(
          'View',
          () => openFlow(
            context,
            const TrackingScreen(result: MockServiceRepository.maintenance),
          ),
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
      const Reveal(
        delay: 45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mon, Sep 22', style: AppTypography.caption),
            SizedBox(height: 7),
            Text(
              'Good Morning,\nShamim',
              style: TextStyle(
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
      const SizedBox(height: 20),
      Reveal(
        delay: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Upcoming service'),
            const SizedBox(height: 9),
            _booking(),
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
    2 => [_section('Your bookings'), const SizedBox(height: 12), _booking()],
    _ => [
      const Text('Your profile', style: AppTypography.title),
      const SizedBox(height: 12),
      GlassSurface(
        child: Column(
          children: [
            const ListTile(
              leading: CircleAvatar(child: Text('S')),
              title: Text('Shamim'),
              subtitle: Text('DetechX demo account'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.mapPin),
              title: Text(_address),
              subtitle: const Text('Default service address'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: _chooseAddress,
            ),
          ],
        ),
      ),
    ],
  };

  Widget _dock() {
    const tabs = [
      (LucideIcons.house, 'Home'),
      (LucideIcons.wrench, 'Services'),
      (LucideIcons.calendarDays, 'Bookings'),
      (LucideIcons.userRound, 'Profile'),
    ];
    return Row(
      children: [
        Expanded(
          child: GlassSurface(
            radius: 99,
            blur: true,
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                for (final (index, tab) in tabs.indexed)
                  Expanded(
                    flex: _tab == index ? 2 : 1,
                    child: SpringScaleTap(
                      label: tab.$2,
                      selected: _tab == index,
                      onTap: () => setState(() => _tab = index),
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 260),
                        curve: motionCurve,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _tab == index
                              ? AppColors.badgePeachBg
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(tab.$1, size: 18),
                            if (_tab == index) ...[
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  tab.$2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
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
  Widget build(BuildContext context) => Scaffold(
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
                              child: const Text(
                                'S',
                                style: TextStyle(
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
  );
}
