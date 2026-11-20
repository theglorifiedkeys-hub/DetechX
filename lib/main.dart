import 'package:flutter/material.dart';
import 'app/preferences.dart';
import 'app/theme.dart';
import 'core/surfaces.dart';
import 'features/home/home_screen.dart';
import 'features/tracking/map_lab.dart';

void main() => runApp(const DetechXApp());

class DetechXApp extends StatefulWidget {
  const DetechXApp({super.key, this.showSplash = true});
  final bool showSplash;
  @override
  State<DetechXApp> createState() => _DetechXAppState();
}

class _DetechXAppState extends State<DetechXApp> {
  final _settings = AppPreferences();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.showSplash) {
      _bootstrap();
    } else {
      _ready = true;
    }
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _settings.load(),
      Future<void>.delayed(const Duration(milliseconds: 850)),
    ]);
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _settings,
    builder: (context, _) => MaterialApp(
      title: 'DetechX',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routes: {'/map': (_) => const MapLab()},
      home: Builder(
        builder: (context) => AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 420),
          switchInCurve: motionCurve,
          child: _ready
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: HomeScreen(settings: _settings),
                  ),
                )
              : const _Splash(),
        ),
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations:
                media.disableAnimations || _settings.reduceMotion,
          ),
          child: ColoredBox(
            color: const Color(0xfff1e6df),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1220),
                child: child!,
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const AmbientCoralBackdrop(center: Alignment(0, 0)),
        Center(
          child: Reveal(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlassSurface(
                  radius: 28,
                  padding: EdgeInsets.all(22),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    child: Image(
                      image: AssetImage('assets/launcher.png'),
                      width: 62,
                      height: 62,
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                Text(
                  'DetechX',
                  style: AppTypography.title.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Huduma za nyumbani · Dar es Salaam',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
