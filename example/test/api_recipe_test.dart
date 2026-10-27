import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_ui_showcase/api_demo.dart';
import 'package:flutter_ui_showcase/recipes/api_recipe.dart';
import 'package:youth_ui/youth_ui.dart';

http.Response json(Object value, int status) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

// Streamed HTTP crosses event-loop and frame boundaries. Drive both clocks
// until the mock request chain finishes, instead of settling a busy spinner.
Future<void> settleHttp(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 16));
    final busy = tester
        .widgetList<UIButton>(find.byType(UIButton))
        .any((button) => button.loading);
    if (!busy) {
      await tester.pumpAndSettle();
      return;
    }
  }
  fail('Mock HTTP request did not settle across frame/event boundaries');
}

void main() {
  test(
    'HTTP GET validates models, keeps base path, and reads current token',
    () async {
      var token = 'session-one';
      final seen = <String?>[];
      final client = MockClient((request) async {
        expect(request.url.toString(), 'https://backend.example/api/members');
        expect(request.followRedirects, isFalse);
        seen.add(request.headers['Authorization']);
        return json([
          {'id': 1, 'name': 'An', 'email': 'an@example.com'},
        ], 200);
      });
      addTearDown(client.close);
      final api = MembersApi(
        client: client,
        baseUrl: Uri.parse('https://backend.example/api'),
        accessToken: () async => token,
      );
      expect((await api.fetchMembers()).single.name, 'An');
      token = 'session-two';
      await api.fetchMembers();
      expect(seen, ['Bearer session-one', 'Bearer session-two']);
    },
  );

  test('HTTP POST sends JSON and maps only named 422 field errors', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(jsonDecode(request.body), {
        'name': 'An',
        'email': 'an@example.com',
      });
      return json({
        'fieldErrors': {'email': 'Already used', 'unrelated': 'Ignore'},
      }, 422);
    });
    addTearDown(client.close);
    final api = MembersApi(
      client: client,
      baseUrl: Uri.parse('https://backend.example/'),
    );
    await expectLater(
      api.createMember(name: 'An', email: 'an@example.com'),
      throwsA(
        isA<UIFormException>().having((e) => e.fieldErrors, 'fieldErrors', {
          'email': 'Already used',
        }),
      ),
    );
  });

  test(
    'HTTP failures and invalid schema are rejected without exposing raw body',
    () async {
      for (final response in [
        http.Response('private server diagnostic', 500),
        json({'wrong': []}, 200),
        json([
          {'id': 'not numeric', 'name': 'An', 'email': 'an@example.com'},
        ], 200),
        http.Response('x' * (1024 * 1024 + 1), 200),
      ]) {
        final client = MockClient((_) async => response);
        final api = MembersApi(
          client: client,
          baseUrl: Uri.parse('https://backend.example/'),
        );
        await expectLater(
          api.fetchMembers(),
          throwsA(anyOf(isA<MembersApiException>(), isA<FormatException>())),
        );
        client.close();
      }
    },
  );

  test('example endpoint configuration rejects insecure remote URLs and credentials', () {
    final client = MockClient((_) async => json([], 200));
    addTearDown(client.close);
    for (final value in [
      'http://remote.example/api',
      'https://user:password@backend.example/',
      'https://backend.example/?token=secret',
      'file:///private',
    ]) {
      expect(
        () => MembersApi(client: client, baseUrl: Uri.parse(value)),
        throwsArgumentError,
      );
    }
  });

  testWidgets(
    'real HTTP recipe shows named errors, saves and refreshes the table',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var posts = 0, gets = 0;
      final rows = [
        <String, Object>{
          'id': 1,
          'name': 'First member',
          'email': 'first@example.com',
        },
      ];
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          gets++;
          return json(rows, 200);
        }
        posts++;
        if (posts == 1) {
          return json({
            'fieldErrors': {'email': 'Email already used'},
          }, 422);
        }
        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        rows.add({
          'id': 2,
          'name': payload['name'] as String,
          'email': payload['email'] as String,
        });
        return json({'id': 2}, 201);
      });
      addTearDown(client.close);
      await tester.pumpWidget(
        UIApp(
          primary: Colors.blue,
          reduceMotion: true,
          home: Scaffold(
            body: ApiMembersPage(
              client: client,
              baseUrl: Uri.parse('https://backend.example/api/'),
            ),
          ),
        ),
      );
      await settleHttp(tester);
      expect(find.text('First member'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Họ tên'),
        'Second member',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'second@example.com',
      );
      await tester.tap(find.text('Thêm thành viên'));
      await settleHttp(tester);
      expect(find.text('Email already used'), findsOneWidget);
      expect(gets, 1);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'new@example.com',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm thành viên'));
      await settleHttp(tester);
      expect(posts, 2);
      expect(gets, 2);
      expect(find.text('Second member'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );

  testWidgets('API gallery exercises data, empty, failure and retry states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const UIApp(
        primary: Colors.blue,
        reduceMotion: true,
        home: Scaffold(body: UIPage(children: [ApiConnectionDemo()])),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nguyễn An'), findsOneWidget);
    await tester.tap(find.text('Dữ liệu rỗng'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có nội dung'), findsOneWidget);
    await tester.tap(find.text('Mô phỏng lỗi'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa thể hoàn tất'), findsOneWidget);
    await tester.ensureVisible(find.text('Thử lại'));
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa thể hoàn tất'), findsOneWidget);
    await tester.ensureVisible(find.text('Có dữ liệu'));
    await tester.tap(find.text('Có dữ liệu'));
    await tester.pumpAndSettle();
    expect(find.text('Nguyễn An'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
