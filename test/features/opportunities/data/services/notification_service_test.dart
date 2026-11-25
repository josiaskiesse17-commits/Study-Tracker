import 'package:flutter_test/flutter_test.dart';

import 'package:study_tracker/features/opportunities/data/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('instance is a singleton', () {
      expect(NotificationService.instance, isA<NotificationService>());
      expect(NotificationService.instance, same(NotificationService.instance));
    });

    test('isSupported getter exists and returns normally', () {
      expect(() => NotificationService.instance.isSupported, returnsNormally);
    });

    test('requestPermission getter exists and returns normally', () {
      expect(
        () => NotificationService.instance.requestPermission,
        returnsNormally,
      );
    });
  });
}
