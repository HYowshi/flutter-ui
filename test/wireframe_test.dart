import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

void main() {
  test(
    'value recognition is conservative and ambiguous layouts are downgraded',
    () {
      expect(
        UIWireframe.inspect({'email': null, 'password': null}).layout,
        UIWireframeLayout.form,
      );
      final values = UIWireframe.inspect({
        'a': 'user@example.test',
        'b': '+84 912 345 678',
        'c': '2026-10-22',
        'd': '2026-02-31',
        'e': '01/02/2026',
        'f': '1234567890',
        'g': 'https://example.test/a.jpg',
      });
      expect(values.fields.map((f) => f.type), [
        UIWireframeFieldType.email,
        UIWireframeFieldType.phone,
        UIWireframeFieldType.date,
        UIWireframeFieldType.text,
        UIWireframeFieldType.text,
        UIWireframeFieldType.text,
        UIWireframeFieldType.image,
      ]);
      final ambiguous = UIWireframe.inspect({
        'name': 'User',
        'avatar': null,
        'email': null,
        'title': 'Post',
        'body': 'Article',
      });
      expect(ambiguous.confidence, UIWireframeConfidence.medium);
      expect(ambiguous.reasons.single, contains('Cũng có dấu hiệu'));
    },
  );
  testWidgets('all schema controls fit a narrow local region', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: SingleChildScrollView(
                child: UIWireframe.auto(
                  fields: [
                    for (final type in UIWireframeFieldType.values)
                      UIWireframeField(type.name, type: type),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(EditableText), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
  final cases = <(Object?, UIWireframeLayout)>[
    ({'title': 'News', 'body': 'Story'}, UIWireframeLayout.article),
    (
      [
        {'title': 'News', 'image': 'cover.png'},
      ],
      UIWireframeLayout.feed,
    ),
    (
      {'name': 'User', 'avatar': null, 'email': null},
      UIWireframeLayout.profile,
    ),
    (
      {'name': 'Book', 'price': 20, 'currency': 'VND'},
      UIWireframeLayout.product,
    ),
    (['a.png', 'https://cdn.test/b.webp?size=400'], UIWireframeLayout.gallery),
    (
      [
        {'sender': 'a', 'text': 'Hello'},
      ],
      UIWireframeLayout.chat,
    ),
    (
      [
        {'date': '2026-10-22', 'event': 'Created'},
      ],
      UIWireframeLayout.timeline,
    ),
    ({'stats': {}, 'series': []}, UIWireframeLayout.dashboard),
    ({'notifications': true, 'darkMode': false}, UIWireframeLayout.settings),
    (
      [
        {'id': 1, 'name': 'A', 'score': 8},
        {'id': 2, 'name': 'B', 'score': 9},
      ],
      UIWireframeLayout.table,
    ),
    ({'Tiêu đề': 'Tin', 'Nội dung': 'Bài viết'}, UIWireframeLayout.article),
    (
      {'Họ tên': 'An', 'Ảnh đại diện': null, 'Vai trò': 'User'},
      UIWireframeLayout.profile,
    ),
    ([], UIWireframeLayout.empty),
    ({}, UIWireframeLayout.empty),
    (null, UIWireframeLayout.detail),
    ('unknown', UIWireframeLayout.detail),
    ([1, 2], UIWireframeLayout.list),
    (
      [
        {'title': 'News', 'body': 'Story'},
        1,
      ],
      UIWireframeLayout.list,
    ),
    ({'title': 'Unit price', 'price': 4}, UIWireframeLayout.detail),
    ({'url': 'https://example.test'}, UIWireframeLayout.detail),
    (
      [
        {'id': 1, 'name': 'A', 'score': 8},
        {'other': true},
      ],
      UIWireframeLayout.list,
    ),
  ];
  for (var i = 0; i < cases.length; i++) {
    test('inference case $i chooses ${cases[i].$2.name}', () {
      final plan = UIWireframe.inspect(cases[i].$1);
      expect(plan.layout, cases[i].$2);
      expect(plan.reasons, isNotEmpty);
    });
  }
  test('API envelope, precedence, explicit schema and hints', () {
    expect(
      UIWireframe.inspect({
        'data': {
          'items': [
            {'title': 'News', 'body': 'Text'},
          ],
        },
        'success': true,
      }).layout,
      UIWireframeLayout.feed,
    );
    expect(
      UIWireframe.inspect([
        {'title': 'Book', 'body': 'Text', 'price': 20, 'sku': 'X'},
      ]).layout,
      UIWireframeLayout.product,
    );
    final forced = UIWireframe.inspect(null, layout: UIWireframeLayout.chat);
    expect(forced.layout, UIWireframeLayout.chat);
    expect(forced.confidence, UIWireframeConfidence.explicit);
    final form = UIWireframe.inspect(
      null,
      fields: const [
        UIWireframeField('Email', type: UIWireframeFieldType.email),
        UIWireframeField('Category', type: UIWireframeFieldType.choice),
      ],
    );
    expect(form.layout, UIWireframeLayout.form);
    final hinted = UIWireframe.inspect(
      {'portrait': null},
      fieldTypes: {'portrait': UIWireframeFieldType.avatar},
    );
    expect(hinted.fields.single.type, UIWireframeFieldType.avatar);
    expect(hinted.confidence, UIWireframeConfidence.low);
  });
  test(
    'field types are inferred without interpreting arbitrary URLs as images',
    () {
      final plan = UIWireframe.inspect({
        'email': null,
        'phone': null,
        'password': 'secret',
        'active': true,
        'score': 42,
        'createdAt': DateTime(2026),
        'cover': null,
        'body': 'Text',
        'nested': {},
        'link': 'https://example.test',
      });
      expect(plan.fields.map((f) => f.type), [
        UIWireframeFieldType.email,
        UIWireframeFieldType.phone,
        UIWireframeFieldType.password,
        UIWireframeFieldType.toggle,
        UIWireframeFieldType.number,
        UIWireframeFieldType.date,
        UIWireframeFieldType.image,
        UIWireframeFieldType.paragraph,
        UIWireframeFieldType.section,
        UIWireframeFieldType.text,
      ]);
    },
  );
  test('inspection is bounded and handles cyclic, null and mixed data', () {
    final cycle = <String, Object?>{};
    cycle['data'] = cycle;
    expect(UIWireframe.inspect(cycle).layout, UIWireframeLayout.detail);
    final many = {for (var i = 0; i < 10000; i++) 'field$i': i};
    expect(UIWireframe.inspect(many).fields.length, 12);
    expect(() => UIWireframe.inspect(null, itemCount: 13), throwsRangeError);
    expect(() => UIWireframe.inspect(null, itemCount: -1), throwsRangeError);
    final original = {'name': 'secret value'};
    final snapshot = UIWireframe.inspect(original);
    original.clear();
    expect(snapshot.fields.single.name, 'name');
    expect(() => snapshot.fields.clear(), throwsUnsupportedError);
    expect(snapshot.reasons.join(), isNot(contains('secret value')));
  });
  for (final width in [280.0, 768.0, 1280.0]) {
    testWidgets('all layouts fit width $width, 200% text, RTL and dark', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final layout in UIWireframeLayout.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 900),
                textScaler: const TextScaler.linear(2),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: UIPage(
                    children: [
                      UIWireframe.auto(
                        data: {'password': 'DO NOT DISPLAY'},
                        layout: layout,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: layout.name);
        expect(find.text('DO NOT DISPLAY'), findsNothing);
        expect(find.byType(Image), findsNothing);
        expect(find.byType(EditableText), findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
      }
    });
  }
  testWidgets(
    'auto fits unbounded horizontal parent and exposes one semantic label',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Row(children: [UIWireframe.auto(data: null)]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Wireframe detail'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
