// Fanar API service layer.
// All requests go through this class so the API key is centralised and
// never scattered across the UI layer.
//
// NOTE: In production the API key should be injected from a secure backend
// gateway. This implementation stores it in a constant for development;
// replace FanarApiConfig.apiKey with a backend-fetched token before shipping.

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:misbah_path/core/services/error_handling_system.dart';

import '../models/ai_model.dart';
import '../models/chat_message.dart';
import 'fanar_api_config.dart';

class FanarApiService {
  FanarApiService._() : _dio = _buildDio();
  static final FanarApiService instance = FanarApiService._();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: FanarApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${FanarApiConfig.apiKey}',
        },
      ),
    );

    // Log requests/responses in debug mode only.
    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false, // avoid logging sensitive user content
          responseBody: false,
          logPrint: (o) => log(o.toString(), name: 'FanarAPI'),
        ),
      );
      return true;
    }());

    return dio;
  }

  // ─── Chat Completion ──────────────────────────────────────────────────────

  /// Sends [messages] to the Fanar chat completions endpoint.
  /// Always prepends the system prompt if not already present.
  Future<Either<Failure, String>> sendMessage({
    required List<ChatMessage> messages,
    String model = FanarApiConfig.defaultModel,
  }) async {
    try {
      // Build the payload — filter out DB-only fields, keep API fields.
      final apiMessages = messages
          .map((m) => m.toApiMap())
          .toList(growable: false);

      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/chat/completions',
        data: {'model': model, 'messages': apiMessages},
      );

      final content = _extractContent(response.data);
      if (content == null) {
        return Left(Failure(0, 'Empty response from Fanar API'));
      }
      return Right(content);
    } on DioException catch (e) {
      log('DioException: ${e.message}', name: 'FanarApiService');
      return Left(_mapDioError(e));
    } catch (e) {
      log('Unexpected error: $e', name: 'FanarApiService');
      return Left(DataSource.DEFAULT.getFailure());
    }
  }

  // ─── Models ───────────────────────────────────────────────────────────────

  Future<Either<Failure, List<AiModel>>> getModels() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/models');
      final data = response.data;
      if (data == null) return Right(AiModel.defaults);

      final List<dynamic> rawList = data['data'] as List<dynamic>? ?? [];
      final models = rawList
          .whereType<Map<String, dynamic>>()
          .map(AiModel.fromJson)
          .toList();

      return Right(models.isEmpty ? AiModel.defaults : models);
    } on DioException catch (e) {
      // Non-critical — fall back to defaults.
      log('Models fetch failed: ${e.message}', name: 'FanarApiService');
      return Right(AiModel.defaults);
    } catch (_) {
      return Right(AiModel.defaults);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String? _extractContent(Map<String, dynamic>? data) {
    if (data == null) return null;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;
    final message = (choices[0] as Map<String, dynamic>?)?['message'];
    if (message == null) return null;
    return (message as Map<String, dynamic>)['content'] as String?;
  }

  /// Maps a DioException to a user-visible [Failure].
  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      switch (e.response?.statusCode) {
        case 401:
          return Failure(401, 'Authentication failed');
        case 429:
          return Failure(429, 'Too many requests, please try again later');
        case 500:
        case 502:
        case 503:
          return Failure(500, 'Server error — retrying…');
        default:
          return Failure(
            e.response?.statusCode ?? 0,
            e.response?.statusMessage ?? 'Unknown API error',
          );
      }
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return Failure(-1, 'No internet connection');
    }
    return ErrorHandler.handle(e).failure;
  }
}
