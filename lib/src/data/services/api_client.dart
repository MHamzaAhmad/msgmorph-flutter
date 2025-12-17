import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:msgmorph_flutter/src/core/constants.dart';
import 'package:msgmorph_flutter/src/core/exceptions.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/data/models/chat_session.dart';
import 'package:msgmorph_flutter/src/data/models/chat_message.dart';
import 'package:msgmorph_flutter/src/data/models/feedback_request.dart';

/// HTTP API client for MsgMorph backend
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  /// Get headers for requests
  Map<String, String> _headers({String? visitorId, String? visitorName}) => {
        'Content-Type': 'application/json',
        if (visitorId != null) 'X-Visitor-Id': visitorId,
        if (visitorName != null) 'X-Visitor-Name': visitorName,
      };

  /// Make a GET request
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? queryParams,
    String? visitorId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams);

    final response = await _httpClient.get(
      uri,
      headers: _headers(visitorId: visitorId),
    );

    return _handleResponse(response);
  }

  /// Make a POST request
  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
    String? visitorId,
    String? visitorName,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await _httpClient.post(
      uri,
      headers: _headers(visitorId: visitorId, visitorName: visitorName),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    String message = 'Request failed';
    String? code;

    try {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      message = errorBody['message'] as String? ?? message;
      code = errorBody['code'] as String?;
    } catch (_) {}

    throw ApiException(message, code: code, statusCode: response.statusCode);
  }

  // ==================== Widget API ====================

  /// Get widget configuration by public ID
  Future<WidgetConfig> getWidgetConfig(String publicId) async {
    final data = await _get(ApiEndpoints.widgetConfig(publicId));
    return WidgetConfig.fromJson(data);
  }

  /// Submit feedback
  Future<FeedbackResponse> submitFeedback(
    String publicId,
    FeedbackRequest request,
  ) async {
    final data = await _post(
      ApiEndpoints.submitFeedback(publicId),
      body: request.toJson(),
    );
    return FeedbackResponse.fromJson(data);
  }

  // ==================== Chat API ====================

  /// Start a new chat session
  Future<StartChatResult> startChat({
    required String projectId,
    required String visitorId,
    String? visitorName,
    String? visitorEmail,
    String? initialMessage,
    String? subject,
    Map<String, dynamic>? metadata,
    DeviceContext? deviceContext,
  }) async {
    final data = await _post(
      ApiEndpoints.startChat,
      body: {
        'projectId': projectId,
        'visitorId': visitorId,
        if (visitorName != null) 'visitorName': visitorName,
        if (visitorEmail != null) 'visitorEmail': visitorEmail,
        if (initialMessage != null) 'initialMessage': initialMessage,
        if (subject != null) 'subject': subject,
        if (metadata != null) 'metadata': metadata,
        if (deviceContext != null) 'deviceContext': deviceContext.toJson(),
      },
    );
    return StartChatResult.fromJson(data);
  }

  /// Recover active session for visitor
  Future<StartChatResult?> recoverSession({
    required String visitorId,
    required String projectId,
  }) async {
    try {
      final data = await _get(
        ApiEndpoints.activeSession,
        queryParams: {'visitorId': visitorId, 'projectId': projectId},
      );

      if (data['session'] == null) {
        return null;
      }

      return StartChatResult.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Get messages for a session
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final data = await _get(ApiEndpoints.sessionMessages(sessionId));
    final messages = data['messages'] as List<dynamic>? ?? [];
    return messages
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Send a message as visitor
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
    required String visitorId,
    String? visitorName,
  }) async {
    final data = await _post(
      ApiEndpoints.sendVisitorMessage(sessionId),
      body: {'content': content},
      visitorId: visitorId,
      visitorName: visitorName,
    );
    return ChatMessage.fromJson(data);
  }

  /// Rate a chat session
  Future<void> rateChat({
    required String sessionId,
    required int rating,
    String? feedback,
  }) async {
    await _post(
      ApiEndpoints.rateSession(sessionId),
      body: {'rating': rating, if (feedback != null) 'feedback': feedback},
    );
  }

  /// Check agent availability
  Future<bool> checkAvailability(String projectId) async {
    try {
      final data = await _get(
        ApiEndpoints.checkAvailability,
        queryParams: {'projectId': projectId},
      );
      return data['isAvailable'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}
