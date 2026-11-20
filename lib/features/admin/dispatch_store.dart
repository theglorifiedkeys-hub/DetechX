import 'package:flutter/foundation.dart';

enum JobStage {
  unassigned('Unassigned'),
  assigned('Assigned'),
  onSite('On site'),
  complete('Complete');

  const JobStage(this.label);
  final String label;
}

@immutable
class DispatchJob {
  const DispatchJob(
    this.id,
    this.service,
    this.area,
    this.amount,
    this.stage, {
    this.technician,
    this.paid = false,
  });
  final String id, service, area;
  final int amount;
  final JobStage stage;
  final String? technician;
  final bool paid;

  DispatchJob copyWith({JobStage? stage, String? technician, bool? paid}) =>
      DispatchJob(
        id,
        service,
        area,
        amount,
        stage ?? this.stage,
        technician: technician ?? this.technician,
        paid: paid ?? this.paid,
      );
}

class DemoDispatchStore extends ChangeNotifier {
  static const technicians = ['Juma Msuya', 'Asha Selemani', 'Baraka Mushi'];
  final _jobs = <DispatchJob>[
    const DispatchJob(
      'DX-104',
      'AC diagnostic',
      'Mikocheni',
      45000,
      JobStage.unassigned,
    ),
    const DispatchJob(
      'DX-103',
      'Kitchen leak',
      'Sinza',
      40000,
      JobStage.assigned,
      technician: 'Asha Selemani',
    ),
    const DispatchJob(
      'DX-102',
      'Outlet inspection',
      'Upanga',
      50000,
      JobStage.onSite,
      technician: 'Baraka Mushi',
    ),
    const DispatchJob(
      'DX-101',
      'AC servicing',
      'Masaki',
      65000,
      JobStage.complete,
      technician: 'Juma Msuya',
      paid: true,
    ),
  ];
  List<DispatchJob> get jobs => List.unmodifiable(_jobs);

  void _update(String id, DispatchJob Function(DispatchJob) change) {
    final index = _jobs.indexWhere((job) => job.id == id);
    if (index == -1) return;
    final next = change(_jobs[index]);
    if (identical(next, _jobs[index])) return;
    _jobs[index] = next;
    notifyListeners();
  }

  void assign(String id, String technician) {
    if (!technicians.contains(technician)) return;
    _update(
      id,
      (job) => job.stage != JobStage.unassigned
          ? job
          : job.copyWith(stage: JobStage.assigned, technician: technician),
    );
  }

  void advance(String id) => _update(
    id,
    (job) => switch (job.stage) {
      JobStage.assigned => job.copyWith(stage: JobStage.onSite),
      JobStage.onSite => job.copyWith(stage: JobStage.complete),
      _ => job,
    },
  );

  void recordTestPayment(String id) => _update(
    id,
    (job) => job.stage == JobStage.complete && !job.paid
        ? job.copyWith(paid: true)
        : job,
  );
}
