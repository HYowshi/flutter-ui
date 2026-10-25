import 'package:flutter/foundation.dart';

enum UIWireframeLayout {
  feed,
  dashboard,
  form,
  profile,
  article,
  product,
  gallery,
  chat,
  table,
  settings,
  timeline,
  detail,
  list,
  empty,
  landing,
  event,
  pricing,
}

/// Evidence strength, not a calibrated probability of correctness.
enum UIWireframeConfidence { explicit, high, medium, low }

enum UIWireframeFieldType {
  text,
  paragraph,
  number,
  date,
  email,
  phone,
  image,
  avatar,
  toggle,
  choice,
  password,
  section,
}

@immutable
class UIWireframeField {
  const UIWireframeField(this.name, {this.type = UIWireframeFieldType.text});
  final String name;
  final UIWireframeFieldType type;
}

/// Immutable, value-free snapshot. Safe to reuse across theme/layout rebuilds.
@immutable
class UIWireframePlan {
  UIWireframePlan({
    required this.layout,
    required this.confidence,
    required List<String> reasons,
    required List<UIWireframeField> fields,
    required this.itemCount,
    this.isCollection = false,
  }) : reasons = List.unmodifiable(reasons),
       fields = List.unmodifiable(fields.take(12)) {
    if (itemCount < 0 || itemCount > 12) {
      throw RangeError.range(itemCount, 0, 12, 'itemCount');
    }
  }
  final UIWireframeLayout layout;
  final UIWireframeConfidence confidence;
  final List<String> reasons;
  final List<UIWireframeField> fields;
  final int itemCount;
  final bool isCollection;
}

/// Bounded structural heuristics. Never traverses arbitrary object graphs,
/// calls a model, downloads media or retains input values.
class UIWireframeInference {
  UIWireframeInference._();
  static String _key(String key) {
    var result = key.substring(0, key.length.clamp(0, 100)).toLowerCase();
    const groups = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };
    for (final entry in groups.entries) {
      for (final rune in entry.value.runes) {
        result = result.replaceAll(String.fromCharCode(rune), entry.key);
      }
    }
    return result.replaceAll(RegExp('[^a-z0-9]'), '');
  }

  static bool _image(Object? value) {
    if (value is! String || value.length > 2048) return false;
    final path = Uri.tryParse(value)?.path.toLowerCase() ?? '';
    return RegExp(r'\.(png|jpe?g|webp|gif|avif)$').hasMatch(path);
  }

  static UIWireframeFieldType _type(String key, Object? value) {
    bool named(String keys) => keys.split('|').contains(key);
    if (named('password|matkhau|confirmpassword')) {
      return UIWireframeFieldType.password;
    }
    if (named('avatar|avatarurl|profilepicture|anhdaidien')) {
      return UIWireframeFieldType.avatar;
    }
    if (named(
          'image|imageurl|thumbnail|thumbnailurl|cover|coverimage|heroimage|banner|poster|photo|anh|hinhanh|anhbia',
        ) ||
        _image(value)) {
      return UIWireframeFieldType.image;
    }
    if (named('email|emailaddress')) return UIWireframeFieldType.email;
    if (named('phone|phonenumber|sodienthoai')) {
      return UIWireframeFieldType.phone;
    }
    if (value is bool) return UIWireframeFieldType.toggle;
    if (value is DateTime ||
        named(
          'date|createdat|updatedat|timestamp|startdate|startsat|enddate|endsat|ngay|ngaytao|ngaybatdau',
        )) {
      return UIWireframeFieldType.date;
    }
    if (value is num) return UIWireframeFieldType.number;
    if (value is Map || value is List) return UIWireframeFieldType.section;
    if (value is String && value.length <= 256) {
      if (RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
        return UIWireframeFieldType.email;
      }
      if (RegExp(r'^\+[1-9][0-9 ()-]{7,20}$').hasMatch(value) &&
          value.replaceAll(RegExp(r'\D'), '').length <= 15) {
        return UIWireframeFieldType.phone;
      }
      if (RegExp(r'^\d{4}-\d{2}-\d{2}(T.*)?$').hasMatch(value)) {
        final date = DateTime.tryParse(value.substring(0, 10));
        if (date != null &&
            date.toIso8601String().startsWith(value.substring(0, 10)) &&
            DateTime.tryParse(value) != null) {
          return UIWireframeFieldType.date;
        }
      }
    }
    if (value is String && value.length > 120 ||
        named('body|content|description|noidung|mota')) {
      return UIWireframeFieldType.paragraph;
    }
    return UIWireframeFieldType.text;
  }

  static UIWireframePlan inspect(
    Object? data, {
    UIWireframeLayout? layout,
    List<UIWireframeField> fields = const [],
    Map<String, UIWireframeFieldType> fieldTypes = const {},
    int itemCount = 3,
  }) {
    if (itemCount < 0 || itemCount > 12) {
      throw RangeError.range(itemCount, 0, 12, 'itemCount');
    }
    // Common API envelopes only; at most three hops, never recursive.
    var source = data;
    for (var depth = 0; depth < 3 && source is Map; depth++) {
      final keys = source.keys.take(65).toList();
      if (keys.length > 64 ||
          !keys.every(
            (k) =>
                k is String &&
                [
                  'data',
                  'items',
                  'results',
                  'total',
                  'page',
                  'limit',
                  'meta',
                  'success',
                  'pagination',
                  'count',
                  'hasnext',
                  'nextcursor',
                ].contains(_key(k)),
          )) {
        break;
      }
      final candidates = keys
          .where(
            (k) => ['data', 'items', 'results'].contains(_key(k as String)),
          )
          .toList();
      if (candidates.length != 1) break;
      final next = source[candidates.single];
      if (next is! Map && next is! List) break;
      if (identical(next, source)) break;
      source = next;
    }
    final collection = source is List;
    final sample = source is List ? source.take(8).toList() : <Object?>[source];
    final records = sample.whereType<Map>().toList();
    // Normalize sampled records once and reuse for every candidate rule.
    final normalizedRecords = [
      for (final record in records)
        <String, Object?>{
          for (final entry in record.entries.take(64))
            if (entry.key is String) _key(entry.key as String): entry.value,
        },
    ];
    final entries = <String, Object?>{};
    for (final record in normalizedRecords) {
      for (final entry in record.entries) {
        if (entries.length < 64 &&
            (!entries.containsKey(entry.key) || entries[entry.key] == null)) {
          entries[entry.key] = entry.value;
        }
      }
    }
    // Only look inside a specifically named hero section, never arbitrary graphs.
    final hero = entries['hero'];
    final heroRecord = hero is Map
        ? <String, Object?>{
            for (final e in hero.entries.take(32))
              if (e.key is String) _key(e.key as String): e.value,
          }
        : <String, Object?>{};
    final hints = {
      for (final e in fieldTypes.entries.take(64)) _key(e.key): e.value,
    };
    // Inspect all bounded keys; rendering is limited separately to 12 fields.
    final allFields = [
      for (final entry in entries.entries)
        UIWireframeField(
          entry.key,
          type: hints[entry.key] ?? _type(entry.key, entry.value),
        ),
    ];
    if (heroRecord.isNotEmpty) {
      allFields.addAll([
        for (final entry in heroRecord.entries)
          UIWireframeField(
            'hero.${entry.key}',
            type: _type(entry.key, entry.value),
          ),
      ]);
    }
    if (allFields.length > 12) {
      int priority(UIWireframeField f) =>
          f.type == UIWireframeFieldType.text ||
              f.type == UIWireframeFieldType.number
          ? ([
                  'title',
                  'headline',
                  'name',
                  'price',
                  'cta',
                  'primaryaction',
                ].contains(f.name)
                ? 0
                : 1)
          : 0;
      final indexed = allFields.indexed.toList()
        ..sort((a, b) {
          final order = priority(a.$2).compareTo(priority(b.$2));
          return order == 0 ? a.$1.compareTo(b.$1) : order;
        });
      allFields
        ..clear()
        ..addAll(indexed.map((e) => e.$2));
    }
    final inferred = fields.isNotEmpty
        ? fields.take(12).toList()
        : allFields.take(12).toList();
    UIWireframePlan result(
      UIWireframeLayout selected,
      UIWireframeConfidence confidence,
      String reason,
    ) => UIWireframePlan(
      layout: layout ?? selected,
      confidence: layout == null ? confidence : UIWireframeConfidence.explicit,
      reasons: [layout == null ? reason : 'Bố cục do người gọi chỉ định.'],
      fields: inferred,
      itemCount: itemCount,
      isCollection: collection,
    );
    if (layout != null) {
      return result(layout, UIWireframeConfidence.explicit, '');
    }
    if (fields.isNotEmpty) {
      return result(
        UIWireframeLayout.form,
        UIWireframeConfidence.explicit,
        'Danh sách trường form được chỉ định.',
      );
    }
    if (source is List && source.isEmpty || source is Map && source.isEmpty) {
      return result(
        UIWireframeLayout.empty,
        UIWireframeConfidence.high,
        'Tập dữ liệu rỗng; không giả định nội dung đang tải.',
      );
    }
    bool has(String aliases) => aliases.split('|').any(entries.containsKey);
    bool typed(UIWireframeFieldType type) =>
        allFields.any((f) => f.type == type);
    final candidates = <(UIWireframeLayout, int, String)>[];
    void vote(
      UIWireframeLayout candidate,
      bool condition,
      int weight,
      String reason,
    ) {
      if (condition) candidates.add((candidate, weight, reason));
    }

    final title = has('title|headline|tieude');
    final body = has('body|content|noidung');
    final person = has('name|fullname|displayname|hoten|ten');
    final image = typed(UIWireframeFieldType.image);
    final recordCollection =
        collection && records.isNotEmpty && records.length == sample.length;
    bool coherent(bool Function(Map<String, Object?>) matches) {
      if (records.isEmpty || collection && !recordCollection) return false;
      final matching = normalizedRecords.where(matches).length;
      return matching >= (records.length * .6).ceil();
    }

    bool includes(Map<String, Object?> record, String aliases) =>
        aliases.split('|').any(record.containsKey);
    bool actions(Map<String, Object?> record) => includes(
      record,
      'cta|primaryaction|actionlabel|calltoaction|registerurl|registrationurl|dangky|hanhdong',
    );
    bool heading(Map<String, Object?> record) =>
        includes(record, 'title|headline|heading|tieude|name|ten');
    bool marketing(Map<String, Object?> record) =>
        heading(record) &&
        actions(record) &&
        includes(
          record,
          'subtitle|tagline|benefits|features|heroimage|banner|mota|loiich',
        );
    vote(
      UIWireframeLayout.landing,
      !collection && (marketing(entries) || marketing(heroRecord)),
      108,
      'Tiêu đề, lợi ích/ảnh chủ đạo và hành động chính gợi ý trang giới thiệu.',
    );
    vote(
      UIWireframeLayout.event,
      coherent(
        (r) =>
            heading(r) &&
            includes(r, 'startsat|startdate|date|ngaybatdau|ngay') &&
            includes(r, 'venue|location|diadiem') &&
            (actions(r) ||
                includes(r, 'organizer|agenda|ticketprice|bantochuc')),
      ),
      112,
      'Sự kiện có tên, lịch, địa điểm và thông tin tham gia/tổ chức.',
    );
    final pricingRecords =
        entries['plans'] ?? entries['packages'] ?? entries['goidichvu'];
    bool pricePlan(Map<String, Object?> r) =>
        heading(r) &&
        includes(r, 'price|gia') &&
        includes(r, 'features|benefits|loiich') &&
        includes(r, 'billingperiod|interval|chuky');
    final nestedPricing =
        pricingRecords is List &&
        pricingRecords.isNotEmpty &&
        pricingRecords
            .take(8)
            .every(
              (row) =>
                  row is Map &&
                  pricePlan({
                    for (final e in row.entries.take(32))
                      if (e.key is String) _key(e.key as String): e.value,
                  }),
            );
    vote(
      UIWireframeLayout.pricing,
      (collection && coherent(pricePlan)) || !collection && nestedPricing,
      114,
      'Các gói có giá, chu kỳ thanh toán và danh sách tính năng.',
    );
    final homogeneous =
        collection &&
        records.length == sample.length &&
        records.isNotEmpty &&
        normalizedRecords.every(
          (r) => r.keys.toSet().containsAll(entries.keys),
        );
    vote(
      UIWireframeLayout.chat,
      recordCollection &&
          has('message|text|tinnhan') &&
          has('sender|senderid|from|nguoigui') &&
          coherent(
            (r) =>
                includes(r, 'sender|senderid|from|nguoigui') &&
                includes(r, 'message|text|tinnhan'),
          ),
      100,
      'Nhiều tin nhắn có trường người gửi.',
    );
    vote(
      UIWireframeLayout.form,
      !collection &&
          typed(UIWireframeFieldType.password) &&
          (typed(UIWireframeFieldType.email) ||
              typed(UIWireframeFieldType.phone)),
      110,
      'Trường mật khẩu đi cùng email/số điện thoại gợi ý form tài khoản.',
    );
    vote(
      UIWireframeLayout.product,
      (!collection || recordCollection) &&
          has('price|gia') &&
          has('sku|currency|stock|giatien|tonkho') &&
          (person || title || image) &&
          coherent(
            (r) =>
                includes(r, 'price|gia') &&
                includes(r, 'sku|currency|stock|giatien|tonkho') &&
                (heading(r) || includes(r, 'image|imageurl|photo|anh')),
          ),
      105,
      'Giá, thông tin hàng hóa và tên/ảnh sản phẩm.',
    );
    vote(
      UIWireframeLayout.profile,
      !collection &&
          person &&
          typed(UIWireframeFieldType.avatar) &&
          has('bio|email|role|gioithieu|vaitro'),
      95,
      'Tên, ảnh đại diện và thông tin cá nhân.',
    );
    vote(
      UIWireframeLayout.article,
      !collection && title && body,
      95,
      'Một bản ghi có tiêu đề và nội dung bài viết.',
    );
    vote(
      UIWireframeLayout.feed,
      recordCollection &&
          title &&
          (body || image) &&
          coherent(
            (r) =>
                includes(r, 'title|headline|tieude') &&
                includes(
                  r,
                  'body|content|noidung|image|imageurl|thumbnail|cover|photo|anh|hinhanh',
                ),
          ),
      85,
      'Danh sách có tiêu đề và nội dung/ảnh.',
    );
    vote(
      UIWireframeLayout.timeline,
      recordCollection &&
          has('date|createdat|timestamp|ngay') &&
          has('event|action|sukien|hoatdong'),
      90,
      'Chuỗi sự kiện có mốc thời gian.',
    );
    vote(
      UIWireframeLayout.dashboard,
      !collection &&
          has('stats|metrics|kpis|thongke') &&
          has('series|chart|trend|bieudo'),
      100,
      'Nhóm chỉ số và chuỗi biểu đồ.',
    );
    final toggles = allFields
        .where((f) => f.type == UIWireframeFieldType.toggle)
        .length;
    vote(
      UIWireframeLayout.settings,
      !collection && toggles >= 2 && !has('price|gia|body|content'),
      75,
      'Nhiều tùy chọn bật/tắt trong một bản ghi.',
    );
    final gallery =
        collection &&
        sample.isNotEmpty &&
        sample.every(
          (item) =>
              _image(item) ||
              item is Map &&
                  item.entries
                      .take(64)
                      .any(
                        (e) =>
                            e.key is String &&
                            [
                              'image',
                              'imageurl',
                              'photo',
                              'url',
                              'anh',
                            ].contains(_key(e.key as String)) &&
                            _image(e.value),
                      ),
        );
    vote(
      UIWireframeLayout.gallery,
      gallery && !title && !body,
      90,
      'Tập ảnh có đường dẫn định dạng ảnh được nhận diện.',
    );
    vote(
      UIWireframeLayout.table,
      homogeneous &&
          entries.length >= 3 &&
          !typed(UIWireframeFieldType.paragraph) &&
          !image &&
          !typed(UIWireframeFieldType.section),
      55,
      'Các bản ghi đồng nhất, nhiều trường ngắn phù hợp dạng bảng.',
    );
    candidates.sort((a, b) {
      final weight = b.$2.compareTo(a.$2);
      return weight != 0 ? weight : a.$1.index.compareTo(b.$1.index);
    });
    if (candidates.isNotEmpty) {
      final best = candidates.first;
      final ambiguous =
          candidates.length > 1 && best.$2 - candidates[1].$2 < 15;
      return result(
        best.$1,
        best.$2 >= 85 && !ambiguous
            ? UIWireframeConfidence.high
            : UIWireframeConfidence.medium,
        ambiguous
            ? '${best.$3} Cũng có dấu hiệu ${candidates[1].$1.name}; nên chỉ định layout nếu đã biết màn hình.'
            : best.$3,
      );
    }
    return result(
      collection ? UIWireframeLayout.list : UIWireframeLayout.detail,
      UIWireframeConfidence.low,
      'Chưa đủ dấu hiệu ngữ nghĩa; dùng bố cục trung tính.',
    );
  }
}
