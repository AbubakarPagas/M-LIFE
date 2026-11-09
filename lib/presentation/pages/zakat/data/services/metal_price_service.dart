// ─────────────────────────────────────────────────────────────────────────────
// MetalPriceService — fetches live gold & silver prices
// Caches results in shared_preferences for offline mode
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/metal_price_model.dart';

class MetalPriceService {
  static const _cacheKey = 'zakat_metal_prices';
  static const _cacheDurationHours = 6;

  // goldapi.io — free tier, 1000 req/month
  // We use troy-oz prices then convert: 1 troy oz = 31.1035 grams
  static const _goldApiBase = 'https://www.goldapi.io/api';
  static const _goldApiKey = 'goldapi-demo'; // replace with real key

  // Alternative: metals-api.com (fallback, not currently used)

  final Dio _dio;

  MetalPriceService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  static const double _troyOzToGrams = 31.1035;

  /// Fetch prices. Returns cached value if cache is still fresh.
  Future<MetalPriceModel> fetchPrices({
    String currency = 'USD',
    bool forceRefresh = false,
  }) async {
    // 1. Try cache first (unless forced)
    if (!forceRefresh) {
      final cached = await _loadFromCache();
      if (cached != null) return cached;
    }

    // 2. Try live fetch
    try {
      return await _fetchFromApi(currency);
    } catch (_) {
      // 3. Fall back to stale cache or hardcoded defaults
      final cached = await _loadFromCache(ignoreTtl: true);
      return cached ?? MetalPriceModel.fallback();
    }
  }

  Future<MetalPriceModel> _fetchFromApi(String currency) async {
    // GoldAPI.io endpoint
    // GET https://www.goldapi.io/api/XAU/USD
    try {
      final goldResp = await _dio.get(
        '$_goldApiBase/XAU/$currency',
        options: Options(headers: {'x-access-token': _goldApiKey}),
      );
      final silverResp = await _dio.get(
        '$_goldApiBase/XAG/$currency',
        options: Options(headers: {'x-access-token': _goldApiKey}),
      );

      final goldPricePerOz =
          (goldResp.data['price'] as num?)?.toDouble() ?? 1930.0;
      final silverPricePerOz =
          (silverResp.data['price'] as num?)?.toDouble() ?? 23.0;

      final model = MetalPriceModel(
        goldPerGram: goldPricePerOz / _troyOzToGrams,
        silverPerGram: silverPricePerOz / _troyOzToGrams,
        currency: currency,
        fetchedAt: DateTime.now(),
        isFromCache: false,
      );

      await _saveToCache(model);
      return model;
    } catch (e) {
      rethrow;
    }
  }

  Future<MetalPriceModel?> _loadFromCache({bool ignoreTtl = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final model = MetalPriceModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (ignoreTtl) return model.copyWith(isFromCache: true);
      final age = DateTime.now().difference(model.fetchedAt);
      if (age.inHours < _cacheDurationHours) {
        return model.copyWith(isFromCache: true);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(MetalPriceModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(model.toJson()));
    } catch (_) {}
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
