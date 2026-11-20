import 'package:flutter/foundation.dart';

const initialIssue = "My AC is running but the room isn't getting cold.";

@immutable
class DiagnosticResult {
  const DiagnosticResult(this.issue, this.service, this.low, this.high);
  final String issue, service;
  final int low, high;
  String get estimate => '\$$low – \$$high';
}

@immutable
class ChatMessage {
  const ChatMessage(this.text, {this.user = false});
  final String text;
  final bool user;
}

@immutable
class TechnicianProfile {
  const TechnicianProfile(
    this.name,
    this.specialty,
    this.jobs,
    this.rating,
    this.plate,
  );
  final String name, specialty, rating, plate;
  final int jobs;
}

class MockServiceRepository {
  const MockServiceRepository();
  static const addresses = ['Brooklyn, NY', 'Park Slope, NY', 'Queens, NY'];
  static const technician = TechnicianProfile(
    'Mike Richardson',
    'HVAC Specialist',
    248,
    '4.9',
    'NY • DX 248',
  );
  static const maintenance = DiagnosticResult(
    'Scheduled maintenance visit',
    'AC Maintenance',
    89,
    149,
  );
  DiagnosticResult diagnose(String issue, String answer) {
    final text = issue.toLowerCase();
    if (text.contains(RegExp(r'plumb|sink|pipe|drain|faucet|toilet')))
      return const DiagnosticResult(
        'Possible blockage or fixture leak',
        'Plumbing Diagnostic',
        79,
        145,
      );
    if (text.contains(RegExp(r'electri|outlet|breaker|sparking')))
      return const DiagnosticResult(
        'A circuit or fixture needs inspection',
        'Electrical Diagnostic',
        95,
        165,
      );
    if (!isHvac(issue))
      return const DiagnosticResult(
        'An on-site inspection can narrow down the cause',
        'Home Maintenance Diagnostic',
        79,
        139,
      );
    return switch (answer) {
      'Weak' => const DiagnosticResult(
        'Clogged air filter or blower motor issue',
        'AC Diagnostic & Repair',
        75,
        135,
      ),
      'Normal' => const DiagnosticResult(
        'Airflow or refrigerant-related issue',
        'AC Diagnostic & Repair',
        89,
        149,
      ),
      _ => const DiagnosticResult(
        'Cooling system needs an airflow and temperature check',
        'AC Diagnostic & Repair',
        85,
        155,
      ),
    };
  }

  bool isHvac(String issue) => RegExp(
    r'\bac\b|airflow|hvac|cooling|conditioner|thermostat',
    caseSensitive: false,
  ).hasMatch(issue);
}
