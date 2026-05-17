// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const _apiKey = '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';
  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'gpt-oss-120b:free';

  Future<String> _call(String prompt) async {
    try {
      final response = await http.post(Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://khwamroo.app',
          'X-Title': 'KhwamRoo',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? '';
      } else {
        return 'เกิดข้อผิดพลาด: ${response.statusCode}';
      }
    } catch (e) {
      return 'ไม่สามารถเชื่อมต่อได้';
    }
  }

  // ── Summarize ─────────────────────────────────────
  Future<String> summarize({
    required String title,
    required String body,
  }) async {
    final prompt = '''
สรุปบทความต่อไปนี้เป็นภาษาไทย ให้กระชับ เข้าใจง่าย 3-5 ประโยค
ไม่ต้องขึ้นต้นด้วย "บทความนี้" หรือ "สรุปว่า"

หัวข้อ: $title
เนื้อหา: $body
''';
    return _call(prompt);
  }

  // ── Moderation ────────────────────────────────────
  Future<ModerationResult> moderate({
    required String title,
    required String body,
    required String category,
  }) async {
    final prompt = '''
คุณคือระบบตรวจสอบบทความสำหรับ community platform ชื่อ KhwamRoo
platform นี้รับเฉพาะบทความที่มีสาระใน: การเงิน, การเรียน, กีฬา, เกม, Mindset, Career

ตรวจสอบโพสต์นี้:
หมวด: $category
หัวข้อ: $title
เนื้อหา: $body

ตอบเป็น JSON เท่านั้น ห้ามมีข้อความอื่น:
{"passed": true, "reason": "เหตุผลสั้นๆ"}

reject ถ้า: เป็นดราม่า, ไม่ตรงหมวด, ไม่มีสาระ, spam
''';

    try {
      final text = await _call(prompt);
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch == null) {
        return ModerationResult(passed: true, reason: '');
      }
      final jsonStr = jsonMatch.group(0)!;
      final passed = jsonStr.contains('"passed": true') ||
          jsonStr.contains('"passed":true');
      final reasonMatch =
      RegExp(r'"reason":\s*"([^"]*)"').firstMatch(jsonStr);
      final reason = reasonMatch?.group(1) ?? '';
      return ModerationResult(passed: passed, reason: reason);
    } catch (e) {
      return ModerationResult(passed: true, reason: '');
    }
  }
}

class ModerationResult {
  final bool passed;
  final String reason;
  ModerationResult({required this.passed, required this.reason});
}