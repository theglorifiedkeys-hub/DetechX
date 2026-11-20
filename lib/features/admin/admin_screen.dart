import 'package:flutter/material.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/surfaces.dart';
import '../service_data.dart';
import '../tracking/map_lab.dart';
import 'dispatch_store.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _store = DemoDispatchStore();
  JobStage? _filter;
  String _query = '';

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  Future<void> _assign(DispatchJob job) async {
    final tech = await showPanel<String>(context, 'Assign ${job.id}', [
      for (final name in DemoDispatchStore.technicians)
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(name),
          onTap: () => Navigator.pop(context, name),
        ),
    ]);
    if (mounted && tech != null) _store.assign(job.id, tech);
  }

  Widget _metric(String label, String value, IconData icon) => GlassSurface(
    radius: 22,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.auraCoralDeep),
        const SizedBox(height: 10),
        Text(value, style: AppTypography.title.merge(AppTypography.number)),
        const SizedBox(height: 3),
        Text(label, style: AppTypography.caption),
      ],
    ),
  );

  Widget _job(DispatchJob job) {
    final (String action, VoidCallback callback) = switch (job.stage) {
      JobStage.unassigned => ('Assign fundi', () => _assign(job)),
      JobStage.assigned => ('Mark on site', () => _store.advance(job.id)),
      JobStage.onSite => ('Complete job', () => _store.advance(job.id)),
      JobStage.complete => (
        'Record test payment',
        () => _store.recordTestPayment(job.id),
      ),
    };
    return GlassSurface(
      radius: 20,
      shadow: false,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${job.id} · ${job.service}',
                  style: AppTypography.label,
                ),
              ),
              const SizedBox(width: 7),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.badgePeachBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  child: Text(job.stage.label, style: AppTypography.caption),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${job.area} · ${job.technician ?? 'No technician'}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 9,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                formatTzs(job.amount),
                style: AppTypography.label.merge(AppTypography.number),
              ),
              if (job.paid)
                const Text(
                  'Test payment recorded',
                  style: AppTypography.caption,
                )
              else
                PillButton(
                  action,
                  () {
                    callback();
                  },
                  height: 36,
                  dark: false,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('DetechX Operations'),
      actions: [
        IconButton(
          tooltip: 'Compare maps',
          icon: const Icon(Icons.map_outlined),
          onPressed: () => openFlow(context, const MapLab()),
        ),
      ],
    ),
    body: Stack(
      children: [
        const AmbientCoralBackdrop(center: Alignment(.9, -.6)),
        SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: _store,
            builder: (context, _) {
              final jobs = _store.jobs;
              final filtered = jobs.where(
                (job) =>
                    (_filter == null || job.stage == _filter) &&
                    '${job.id} ${job.area} ${job.service} ${job.technician ?? ''}'
                        .toLowerCase()
                        .contains(_query),
              );
              return LayoutBuilder(
                builder: (context, limits) {
                  final wide = limits.maxWidth >= 800;
                  final padding = wide ? 32.0 : 16.0;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padding, 16, padding, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'OPERATIONS PREVIEW  /  DAR ES SALAAM',
                          style: AppTypography.caption.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Dispatch overview',
                          style: AppTypography.title.copyWith(
                            fontSize: wide ? 36 : 27,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Sample jobs only. Changes reset when you leave this dashboard.',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [
                            for (final (label, value, icon) in [
                              (
                                'Open jobs',
                                '${jobs.where((j) => j.stage != JobStage.complete).length}',
                                Icons.work_outline,
                              ),
                              (
                                'Unassigned',
                                '${jobs.where((j) => j.stage == JobStage.unassigned).length}',
                                Icons.person_add_alt,
                              ),
                              (
                                'On site',
                                '${jobs.where((j) => j.stage == JobStage.onSite).length}',
                                Icons.location_on_outlined,
                              ),
                              (
                                'Test payments',
                                formatTzs(
                                  jobs
                                      .where((j) => j.paid)
                                      .fold<int>(0, (sum, j) => sum + j.amount),
                                ),
                                Icons.receipt_long_outlined,
                              ),
                            ])
                              SizedBox(
                                width:
                                    (limits.maxWidth -
                                            padding * 2 -
                                            (wide ? 27 : 9)) /
                                        (wide ? 4 : 2) -
                                    .1,
                                child: _metric(label, value, icon),
                              ),
                          ],
                        ),
                        const SizedBox(height: 23),
                        const Text('Job queue', style: AppTypography.title),
                        const SizedBox(height: 10),
                        GlassSurface(
                          radius: 18,
                          shadow: false,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            onChanged: (value) => setState(
                              () => _query = value.trim().toLowerCase(),
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText:
                                  'Search job, service, neighborhood or fundi',
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 6,
                          runSpacing: 3,
                          children: [
                            for (final stage in [null, ...JobStage.values])
                              ChoiceChip(
                                label: Text(stage?.label ?? 'All jobs'),
                                selected: _filter == stage,
                                onSelected: (_) =>
                                    setState(() => _filter = stage),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text('No jobs match this search.'),
                          ),
                        for (final job in filtered)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: _job(job),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
