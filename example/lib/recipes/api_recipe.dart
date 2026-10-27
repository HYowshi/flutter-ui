import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youth_ui/youth_ui.dart';

/// Run with --dart-define=API_BASE_URL=https://your-server.example/api/
/// No endpoint is contacted until the application supplies a base URL.
void main() => runApp(
  const UIApp(
    primary: Colors.indigo,
    home: Scaffold(body: ApiMembersPage()),
  ),
);

class Member {
  const Member({required this.id, required this.name, required this.email});
  final int id;
  final String name, email;

  factory Member.fromJson(Object? value) => switch (value) {
    {'id': int id, 'name': String name, 'email': String email} => Member(
      id: id,
      name: name,
      email: email,
    ),
    _ => throw const FormatException('Invalid member schema'),
  };
}

class MembersApiException implements Exception {
  const MembersApiException(this.statusCode);
  final int statusCode;
}

/// Example application code, not part of youth_ui's public API. Adapt the
/// endpoint/schema to your backend. The caller owns the injected HTTP client.
class MembersApi {
  MembersApi({required this.client, required Uri baseUrl, this.accessToken}) {
    final local = {'localhost', '127.0.0.1', '::1'}.contains(baseUrl.host);
    if (baseUrl.host.isEmpty ||
        !(baseUrl.scheme == 'https' || baseUrl.scheme == 'http' && local) ||
        baseUrl.userInfo.isNotEmpty ||
        baseUrl.hasQuery ||
        baseUrl.hasFragment) {
      throw ArgumentError(
        'Use an HTTPS base URL without credentials/query/fragment.',
      );
    }
    _baseUrl = baseUrl.replace(
      path: baseUrl.path.endsWith('/') ? baseUrl.path : '${baseUrl.path}/',
    );
  }

  final http.Client client;

  /// Read the current session token per request; do not embed a secret in code
  /// or dart-define. No token is needed for unauthenticated endpoints.
  final Future<String?> Function()? accessToken;
  late final Uri _baseUrl;

  Future<(int, Object?)> _request(String method, {Object? body}) async {
    final request = http.Request(method, _baseUrl.resolve('members'))
      ..followRedirects = false
      ..headers['Accept'] = 'application/json';
    final token = await accessToken?.call();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 20));
    final bytes = <int>[];
    // Bounded response; the application should use server pagination for large lists.
    await for (final chunk in response.stream.timeout(
      const Duration(seconds: 20),
    )) {
      if (bytes.length + chunk.length > 1024 * 1024) {
        throw const FormatException('Response exceeds example limit');
      }
      bytes.addAll(chunk);
    }
    // Do not expose response bodies for unexpected statuses to widgets/logs.
    if (response.statusCode >= 300 && response.statusCode != 422) {
      throw MembersApiException(response.statusCode);
    }
    return (
      response.statusCode,
      bytes.isEmpty ? null : jsonDecode(utf8.decode(bytes)),
    );
  }

  Future<List<Member>> fetchMembers() async {
    final (status, json) = await _request('GET');
    if (status != 200) throw MembersApiException(status);
    if (json is! List) throw const FormatException('Expected member list');
    return List.unmodifiable(json.map(Member.fromJson));
  }

  Future<void> createMember({
    required String name,
    required String email,
  }) async {
    final (status, json) = await _request(
      'POST',
      body: {'name': name, 'email': email},
    );
    if (status == 422) {
      final errors = <String, String>{};
      if (json is Map && json['fieldErrors'] is Map) {
        final fields = json['fieldErrors'] as Map;
        for (final name in ['name', 'email']) {
          final message = fields[name];
          if (message is String && message.trim().isNotEmpty) {
            errors[name] = message;
          }
        }
      }
      throw UIFormException(
        message: errors.isEmpty ? 'Kiểm tra thông tin rồi thử lại.' : null,
        fieldErrors: errors,
      );
    }
    if (status != 200 && status != 201 && status != 204) {
      throw MembersApiException(status);
    }
  }
}

/// Form remains outside the async region so reloading the list keeps edits.
/// Inject a client/base URL for testing, or provide API_BASE_URL when running.
class ApiMembersPage extends StatefulWidget {
  const ApiMembersPage({super.key, this.client, this.baseUrl});
  final http.Client? client;
  final Uri? baseUrl;
  @override
  State<ApiMembersPage> createState() => _ApiMembersPageState();
}

class _ApiMembersPageState extends State<ApiMembersPage> {
  final list = UIAsyncController();
  final name = TextEditingController(), email = TextEditingController();
  late final http.Client client;
  MembersApi? api;

  @override
  void initState() {
    super.initState();
    client = widget.client ?? http.Client();
    const configured = String.fromEnvironment('API_BASE_URL');
    final baseUrl =
        widget.baseUrl ?? (configured.isEmpty ? null : Uri.parse(configured));
    if (baseUrl != null) api = MembersApi(client: client, baseUrl: baseUrl);
  }

  @override
  void dispose() {
    list.dispose();
    name.dispose();
    email.dispose();
    if (widget.client == null) client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = api;
    if (service == null) {
      return const UIStateView.empty(
        title: 'Chưa cấu hình API',
        message: 'Chạy ví dụ với --dart-define=API_BASE_URL=https://your-server.example/api/',
      );
    }
    return UIPage(
      children: [
        const Text(
          'Thành viên · API của ứng dụng',
          style: TextStyle(fontSize: 24),
        ),
        UIForm(
          submitLabel: 'Thêm thành viên',
          onSubmit: () => service.createMember(
            name: name.text.trim(),
            email: email.text.trim(),
          ),
          onSuccess: () {
            name.clear();
            email.clear();
            unawaited(list.reload());
            UINotice.show(context, message: 'Đã thêm thành viên.');
          },
          children: [
            UITextField(
              name: 'name',
              label: 'Họ tên',
              controller: name,
              validator: UIValidators.required(),
            ),
            UITextField(
              name: 'email',
              label: 'Email',
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: UIValidators.combine([
                UIValidators.required(),
                UIValidators.email(),
              ]),
            ),
          ],
        ),
        ListenableBuilder(
          listenable: list,
          builder: (_, _) => UIButton(
            label: 'Tải lại danh sách',
            loading: list.isLoading,
            onPressed: () => unawaited(list.reload()),
          ),
        ),
        SizedBox(
          height: 420,
          child: UIAsyncView<List<Member>>(
            controller: list,
            requestKey: service,
            load: service.fetchMembers,
            isEmpty: (members) => members.isEmpty,
            builder: (_, members) => SingleChildScrollView(
              child: UITable<Member>(
                label: 'Danh sách thành viên',
                rows: members,
                columns: [
                  UITableColumn(
                    label: 'Họ tên',
                    value: (member) => member.name,
                  ),
                  UITableColumn(
                    label: 'Email',
                    value: (member) => member.email,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
