import 'package:detechx/features/admin/dispatch_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'a demo job must be assigned and completed before recording payment',
    () {
      final store = DemoDispatchStore();
      addTearDown(store.dispose);
      DispatchJob job() => store.jobs.first;
      store.advance(job().id);
      store.recordTestPayment(job().id);
      expect(job().stage, JobStage.unassigned);
      expect(job().paid, isFalse);
      store.assign(job().id, DemoDispatchStore.technicians.first);
      expect(job().stage, JobStage.assigned);
      store.advance(job().id);
      expect(job().stage, JobStage.onSite);
      store.advance(job().id);
      expect(job().stage, JobStage.complete);
      store.recordTestPayment(job().id);
      expect(job().paid, isTrue);
    },
  );
}
