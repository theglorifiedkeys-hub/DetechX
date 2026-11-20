import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

const initialIssue = "My AC is running but the room isn't getting cold.";

@immutable
class DiagnosticResult {
  const DiagnosticResult(this.issue, this.service, this.low, this.high);
  final String issue, service;
  final int low, high;
  String get estimate => formatEstimate(low, high);
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
  static const addresses = [
    'Mikocheni',
    'Sinza',
    'Kinondoni',
    'Mbezi Beach',
    'Upanga',
    'Kigamboni',
    'Masaki',
  ];
  static const technician = TechnicianProfile(
    'Juma Msuya',
    'HVAC Specialist',
    248,
    '4.9',
    'T 248 DXA',
  );
  DiagnosticResult diagnose(String issue, String answer) {
    final text = issue.toLowerCase();
    if (text.contains(
      RegExp(r'plumb|sink|pipe|drain|faucet|toilet|bomba|choo|maji'),
    )) {
      return const DiagnosticResult(
        'Possible blockage or fixture leak',
        'Plumbing Diagnostic',
        40000,
        75000,
      );
    }
    if (text.contains(
      RegExp(r'electri|outlet|breaker|sparking|umeme|soketi'),
    )) {
      return const DiagnosticResult(
        'A circuit or fixture needs inspection',
        'Electrical Diagnostic',
        50000,
        90000,
      );
    }
    if (!isHvac(issue)) {
      return const DiagnosticResult(
        'An on-site inspection can narrow down the cause',
        'Home Maintenance Diagnostic',
        40000,
        70000,
      );
    }
    return switch (answer) {
      'Weak' => const DiagnosticResult(
        'Clogged air filter or blower motor issue',
        'AC Diagnostic & Repair',
        35000,
        65000,
      ),
      'Normal' => const DiagnosticResult(
        'Airflow or refrigerant-related issue',
        'AC Diagnostic & Repair',
        45000,
        80000,
      ),
      _ => const DiagnosticResult(
        'Cooling system needs an airflow and temperature check',
        'AC Diagnostic & Repair',
        45000,
        85000,
      ),
    };
  }

  bool isHvac(String issue) => RegExp(
    r'\bac\b|airflow|hvac|cooling|conditioner|thermostat|kiyoyozi',
    caseSensitive: false,
  ).hasMatch(issue);
}

final _tzs = NumberFormat.decimalPattern('en');
String formatEstimate(int low, int high) =>
    'TZS ${_tzs.format(low)} – ${_tzs.format(high)}';
DateTime darTime(DateTime time) => time.toUtc().add(const Duration(hours: 3));
String darGreeting(int hour) => switch (hour) {
  >= 5 && < 12 => 'Habari za asubuhi',
  >= 12 && < 17 => 'Habari za mchana',
  _ => 'Habari za jioni',
};
