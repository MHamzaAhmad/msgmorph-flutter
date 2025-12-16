/// MsgMorph SDK exceptions
library;

/// Base exception for MsgMorph SDK
class MsgMorphException implements Exception {
  const MsgMorphException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() =>
      'MsgMorphException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when SDK is not initialized
class NotInitializedException extends MsgMorphException {
  const NotInitializedException()
    : super('MsgMorph SDK is not initialized. Call MsgMorph.init() first.');
}

/// Exception thrown when API request fails
class ApiException extends MsgMorphException {
  const ApiException(super.message, {super.code, this.statusCode});

  final int? statusCode;

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when widget config is not found
class WidgetNotFoundException extends MsgMorphException {
  const WidgetNotFoundException(String widgetId)
    : super('Widget not found: $widgetId');
}

/// Exception thrown when socket connection fails
class SocketConnectionException extends MsgMorphException {
  const SocketConnectionException(super.message);
}

/// Exception thrown when chat session fails
class ChatSessionException extends MsgMorphException {
  const ChatSessionException(super.message, {super.code});
}
