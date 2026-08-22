import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';

import '../../app/config/app_config.dart';
import '../../domain/entities/invoice_data.dart';
import '../mappers/invoice_mapper.dart';
import 'firebase_bootstrap_service.dart';
import 'ai_prompt_builder.dart';
import 'internet_connection_service.dart';
import 'remote_config_service.dart';

class FirebaseAiService {
  FirebaseAiService(this._firebase, this._config, this._internet);
  final FirebaseBootstrapService _firebase;
  final RemoteConfigService _config;
  final InternetConnectionService _internet;
  static const Duration _requestTimeout = Duration(seconds: 45);

  bool get available => _firebase.available;

  /// AI is usable only when Firebase initialized and its network route works.
  Future<bool> canUseAi() async =>
      available && await _internet.hasInternetAccess();

  GenerativeModel get _model =>
      FirebaseAI.googleAI().generativeModel(model: _config.aiModel);

  Future<String> text(String prompt, {required AiAction action}) async {
    if (!available) throw StateError('Firebase AI is unavailable.');
    // Bound remote work so stalled requests reach the refundable failure path.
    final response = await _model
        .generateContent([
          Content.text(
            AiPromptBuilder.build(
              masterPrompt: _config.aiMasterPrompt,
              action: action,
              task: prompt,
            ),
          ),
        ])
        .timeout(_requestTimeout);
    return _requireText(response.text);
  }

  Future<String> image(
    String imagePath,
    String prompt, {
    required AiAction action,
  }) async {
    if (!available) throw StateError('Firebase AI is unavailable.');
    final bytes = await File(imagePath).readAsBytes();
    final mime = imagePath.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    // Vision requests share the same timeout and non-empty response contract.
    final response = await _model
        .generateContent([
          Content.multi([
            TextPart(
              AiPromptBuilder.build(
                masterPrompt: _config.aiMasterPrompt,
                action: action,
                task: prompt,
              ),
            ),
            InlineDataPart(mime, bytes),
          ]),
        ])
        .timeout(_requestTimeout);
    return _requireText(response.text);
  }

  String _requireText(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      throw StateError('Firebase AI returned an empty response.');
    }
    return text;
  }

  Future<InvoiceData> extractInvoice(
    String imagePath,
    String fallbackText,
  ) async {
    final marketInstruction = AppConfig.usesSaudiInvoiceRules
        ? 'You are extracting a Saudi invoice or receipt. Read Arabic and English exactly from the image. Use SAR and 15% VAT only when supported by the image.'
        : 'You are extracting an international invoice or receipt. Preserve the document language, currency, and tax rate exactly. Never assume Saudi VAT, SAR, or ZATCA fields.';
    final raw = await image(imagePath, '''
$marketInstruction
Return ONLY valid JSON, no markdown. Do not invent missing values.
Use this schema:
{
  "sellerName":"",
  "sellerNameAr":"",
  "vatNumber":"",
  "commercialRegistration":"",
  "invoiceNumber":"",
  "invoiceType":"",
  "issueDate":"",
  "issueTime":"",
  "buyerName":"",
  "buyerVatNumber":"",
  "subtotal":0,
  "discount":0,
  "taxableAmount":0,
  "vatRate":0,
  "vatAmount":0,
  "total":0,
  "currency":"",
  "paymentMethod":"",
  "lineItems":[{"description":"","quantity":1,"unitPrice":0,"vat":0,"total":0}],
  "needsReview":false
}
Fallback OCR that may help:
$fallbackText
''', action: AiAction.invoiceExtraction);
    final decoded = jsonDecode(_stripCodeFence(raw));
    if (decoded is! Map) {
      throw const FormatException('AI invoice output was not an object.');
    }
    return InvoiceMapper.fromMap(Map<String, dynamic>.from(decoded));
  }

  String _stripCodeFence(String input) {
    var value = input.trim();
    if (value.startsWith('```')) {
      value = value.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      value = value.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return value.trim();
  }
}
