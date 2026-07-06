import 'package:aura_mobile/features/auth/data/models/auth_models.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests locking the JSON shape the backend actually emits for
/// `POST /auth/login` and `GET /auth/me`.
///
/// Background: login once failed with a generic "unexpected error" because the
/// backend serialized `intern.division_id` as the JSON *string* `"11"` while
/// the model expects an `int`. `(json['division_id'] as num?)` then threw a
/// `TypeError` deep inside `fromJson`. `flutter analyze` cannot catch that — it
/// only surfaces at runtime — so these tests parse a realistic payload and
/// assert the decoded types, guarding against the same contract drift.
void main() {
  group('LoginResponse.fromJson', () {
    // Mirrors the exact `UserResource` output verified against the running API
    // (see the AuthController login response: {token, token_type, user}).
    final loginJson = <String, dynamic>{
      'token': '42|abcdefghijklmnopqrstuvwxyz',
      'token_type': 'Bearer',
      'user': <String, dynamic>{
        'id': 17,
        'name': 'Boba',
        'email': null,
        'role': 'intern',
        'is_active': true,
        'intern': <String, dynamic>{
          'id': 10,
          'nim': '20304446',
          'phone': null,
          'status': 'active',
          'start_date': '2026-07-05',
          'end_date': '2026-07-31',
          'division_id': 11,
        },
      },
    };

    test('parses the canonical success payload without throwing', () {
      final response = LoginResponse.fromJson(loginJson);

      expect(response.token, '42|abcdefghijklmnopqrstuvwxyz');
      expect(response.tokenType, 'Bearer');
      expect(response.user.id, 17);
      expect(response.user.name, 'Boba');
      expect(response.user.email, isNull);
      expect(response.user.role, 'intern');
      expect(response.user.isActive, isTrue);
    });

    test('decodes the nested intern with an integer division_id', () {
      final intern = LoginResponse.fromJson(loginJson).user.intern;

      expect(intern, isNotNull);
      expect(intern!.id, 10);
      expect(intern.nim, '20304446');
      expect(intern.phone, isNull);
      expect(intern.status, 'active');
      expect(intern.startDate, '2026-07-05');
      expect(intern.endDate, '2026-07-31');
      // The regression guard: this must be an int, not a String. If the API
      // ever reverts to emitting `"11"`, decoding throws here instead of
      // silently surfacing as a generic error at login time.
      expect(intern.divisionId, isA<int>());
      expect(intern.divisionId, 11);
    });
  });

  group('UserModel.fromJson', () {
    test('treats a missing intern (not loaded) as null', () {
      final user = UserModel.fromJson(<String, dynamic>{
        'id': 1,
        'name': 'Supervisor',
        'email': 'sv@example.com',
        'role': 'supervisor',
        'is_active': true,
      });

      expect(user.intern, isNull);
      expect(user.email, 'sv@example.com');
    });

    test('defaults is_active to true when the key is absent', () {
      final user = UserModel.fromJson(<String, dynamic>{
        'id': 2,
        'name': 'Legacy',
        'role': 'intern',
      });

      expect(user.isActive, isTrue);
    });
  });

  group('UserEnvelope.fromJson', () {
    test('unwraps the /auth/me data wrapper', () {
      final envelope = UserEnvelope.fromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 17,
          'name': 'Boba',
          'email': null,
          'role': 'intern',
          'is_active': true,
          'intern': <String, dynamic>{
            'id': 10,
            'nim': '20304446',
            'phone': null,
            'status': 'active',
            'start_date': '2026-07-05',
            'end_date': '2026-07-31',
            'division_id': 11,
          },
        },
      });

      expect(envelope.data.id, 17);
      expect(envelope.data.intern?.divisionId, 11);
    });
  });
}
