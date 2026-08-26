import 'package:deadly/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A reminder carries the session id in its payload so tapping it opens that
/// session's timer. The round trip has to survive real ids, and anything that
/// is not one of ours has to be ignored rather than sent somewhere wrong.
void main() {
  test('a session id survives the round trip', () {
    const id = '3f2a1b4c-5d6e-7f80-9a1b-2c3d4e5f6071';

    final payload = NotificationService.sessionPayload(id);

    expect(NotificationService.sessionIdFromPayload(payload), id);
  });

  test('ignores a payload that is not ours', () {
    expect(NotificationService.sessionIdFromPayload(null), isNull);
    expect(NotificationService.sessionIdFromPayload(''), isNull);
    expect(NotificationService.sessionIdFromPayload('goal:abc'), isNull);
    expect(
      NotificationService.sessionIdFromPayload('abc'),
      isNull,
      reason: 'a bare id could be anything; only our prefix counts',
    );
  });

  test('ignores a prefix with nothing behind it', () {
    expect(
      NotificationService.sessionIdFromPayload('session:'),
      isNull,
      reason: 'an empty id would send the lookup nowhere',
    );
  });

  test('keeps an id containing the separator intact', () {
    const id = 'a:b:c';

    expect(
      NotificationService.sessionIdFromPayload(
        NotificationService.sessionPayload(id),
      ),
      id,
      reason: 'only the first prefix is stripped',
    );
  });
}
