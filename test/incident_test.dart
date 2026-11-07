import 'package:campusapp/models/incident.dart';
import 'package:campusapp/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isAluEmail', () {
    test('accepts ALU student and staff emails', () {
      expect(isAluEmail('a.b@alustudent.com'), true);
      expect(isAluEmail('staff@alueducation.com'), true);
    });
    test('rejects other domains', () {
      expect(isAluEmail('someone@gmail.com'), false);
      expect(isAluEmail(''), false);
    });
  });

  test('statuses start with Submitted and end with Resolved', () {
    expect(incidentStatuses.first, 'Submitted');
    expect(incidentStatuses.last, 'Resolved');
  });
}
