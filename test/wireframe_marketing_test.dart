import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

void main() {
  for (final width in [180.0, 900.0]) {
    testWidgets('inferred media hero and product collections fit $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final sample in <Object>[
        {
          'hero': {
            'headline': 'A',
            'subtitle': 'B',
            'cta': '/go',
            'heroImage': '/cdn/a',
          },
        },
        [
          {'name': 'A', 'price': 1, 'currency': 'VND', 'image': '/cdn/a'},
        ],
        {
          'title': 'A',
          'date': '2026-11-25',
          'venue': 'B',
          'organizer': 'C',
          'poster': '/cdn/a',
        },
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UIWireframe.auto(data: sample),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(EditableText), findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
      }
    });
  }
  test('bounded inspection detects semantic fields beyond the first 12', () {
    final plan = UIWireframe.inspect({
      for (var i = 0; i < 15; i++) 'metadata$i': 'value',
      'email': null,
      'password': null,
    });
    expect(plan.layout, UIWireframeLayout.form);
    expect(plan.fields.length, 12);
    expect(
      plan.fields.any((f) => f.type == UIWireframeFieldType.password),
      isTrue,
    );
  });
  test(
    'detects landing hero with extensionless media and preserves no values',
    () {
      final plan = UIWireframe.inspect({
        'hero': {
          'headline': 'Private headline',
          'subtitle': 'Private text',
          'primaryAction': {'label': 'Begin'},
          'heroImage': 'https://cdn.test/123',
        },
        'features': ['Private feature'],
      });
      expect(plan.layout, UIWireframeLayout.landing);
      expect(plan.confidence, UIWireframeConfidence.high);
      expect(
        plan.fields.any((f) => f.type == UIWireframeFieldType.image),
        isTrue,
      );
      expect(plan.reasons.join(), isNot(contains('Private')));
      expect(plan.fields.map((f) => f.name).join(), isNot(contains('Private')));
    },
  );
  test('Vietnamese campaign, event and pricing need combined evidence', () {
    expect(
      UIWireframe.inspect({'Tiêu đề': 'A', 'Mô tả': 'B', 'Đăng ký': '/join'})
          .layout,
      UIWireframeLayout.landing,
    );
    expect(
      UIWireframe.inspect({
        'Tiêu đề': 'A',
        'Ngày bắt đầu': '2026-11-25',
        'Địa điểm': 'B',
        'Ban tổ chức': 'C',
      }).layout,
      UIWireframeLayout.event,
    );
    expect(
      UIWireframe.inspect({'title': 'A', 'date': '2026-11-25'}).layout,
      UIWireframeLayout.detail,
    );
    expect(
      UIWireframe.inspect({
        'plans': [
          {
            'name': 'Basic',
            'price': 10,
            'billingPeriod': 'month',
            'features': ['A'],
          },
        ],
      }).layout,
      UIWireframeLayout.pricing,
    );
    expect(
      UIWireframe.inspect({
        'plans': [
          {'price': 10},
        ],
      }).layout,
      UIWireframeLayout.detail,
    );
  });
  test(
    'unrelated records cannot combine to invent a product or conversation',
    () {
      expect(
        UIWireframe.inspect([
          {'sender': 'a'},
          {'text': 'b'},
        ]).layout,
        UIWireframeLayout.list,
      );
      expect(
        UIWireframe.inspect([
          {'title': 'a', 'price': 10},
          {'currency': 'VND'},
        ]).layout,
        UIWireframeLayout.list,
      );
      expect(
        UIWireframe.inspect([
          {'title': 'a'},
          {'body': 'b'},
        ]).layout,
        UIWireframeLayout.list,
      );
    },
  );
  test(
    'product collection retains multiplicity and explicit overrides win',
    () {
      final plan = UIWireframe.inspect([
        {'name': 'A', 'price': 1, 'sku': 'a'},
        {'name': 'B', 'price': 2, 'sku': 'b'},
      ]);
      expect(plan.layout, UIWireframeLayout.product);
      expect(plan.isCollection, isTrue);
      expect(
        UIWireframe.inspect({
          'hero': {'headline': 'A', 'subtitle': 'B', 'cta': '/go'},
        }, layout: UIWireframeLayout.article).confidence,
        UIWireframeConfidence.explicit,
      );
    },
  );
  test('nested special cases remain bounded and cycles do not recurse', () {
    final cyclic = <String, Object?>{};
    cyclic['hero'] = cyclic;
    cyclic['plans'] = [cyclic];
    expect(UIWireframe.inspect(cyclic).layout, UIWireframeLayout.detail);
    expect(
      UIWireframe.inspect({
        'data': [
          {'headline': 'A', 'cta': '/go', 'features': []},
        ],
        'pagination': {},
      }).isCollection,
      isTrue,
    );
    final beyondLimit = {
      for (var i = 0; i < 64; i++) 'x$i': i,
      'email': null,
      'password': null,
    };
    expect(UIWireframe.inspect(beyondLimit).layout, UIWireframeLayout.detail);
  });
}
