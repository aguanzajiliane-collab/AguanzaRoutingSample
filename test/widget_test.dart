import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:samplerouting/pages/sample_page.dart';

class _MockApiClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = jsonEncode([
      {'id': 1, 'title': 'Test Item 1', 'body': 'First test body'},
      {'id': 2, 'title': 'Test Item 2', 'body': 'Second test body'},
    ]);

    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  testWidgets('SamplePage loads items and allows deleting a row', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SamplePage(httpClient: _MockApiClient())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Sample Page'), findsOneWidget);
    expect(find.text('Test Item 1'), findsOneWidget);
    expect(find.text('Test Item 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();

    expect(find.text('Test Item 1'), findsNothing);
  });
}
