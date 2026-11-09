// ── Qibla Manual Location Sheet ──────────────────────────────────────────────
// Bottom sheet that lets the user enter lat/lng or a city name.

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:get/get.dart';

import '../controllers/qibla_controller.dart';

class QiblaManualLocationSheet extends StatefulWidget {
  const QiblaManualLocationSheet({super.key});

  @override
  State<QiblaManualLocationSheet> createState() =>
      _QiblaManualLocationSheetState();
}

class _QiblaManualLocationSheetState extends State<QiblaManualLocationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  bool _isSearching = false;
  String? _searchError;

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.40,
      maxChildSize: 0.85,
      builder: (ctx, scrollCtrl) {
        return SingleChildScrollView(
          controller: scrollCtrl,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  'manualLocation'.tr.isEmpty
                      ? 'Set Location Manually'
                      : 'manualLocation'.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 20),

                // ── City search ─────────────────────────────────────────────────
                Text(
                  'searchCity'.tr.isEmpty ? 'Search City' : 'searchCity'.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StyledField(
                        controller: _cityCtrl,
                        hint: 'e.g. Cairo',
                        primary: primary,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SearchButton(
                      isLoading: _isSearching,
                      primary: primary,
                      onTap: _searchCity,
                    ),
                  ],
                ),

                if (_searchError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _searchError!,
                    style: const TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Divider(color: primary.withValues(alpha: 0.20)),
                const SizedBox(height: 12),

                // ── Manual coords ───────────────────────────────────────────────
                Text(
                  'enterCoordinates'.tr.isEmpty
                      ? 'Enter Coordinates'
                      : 'enterCoordinates'.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StyledField(
                        controller: _latCtrl,
                        hint: 'Latitude (e.g. 21.42)',
                        primary: primary,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final n = double.tryParse(v);
                          if (n == null || n < -90 || n > 90) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StyledField(
                        controller: _lngCtrl,
                        hint: 'Longitude (e.g. 39.82)',
                        primary: primary,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final n = double.tryParse(v);
                          if (n == null || n < -180 || n > 180)
                            return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Apply button ────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyManual,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(
                      'apply'.tr.isEmpty ? 'Apply' : 'apply'.tr,
                      style: const TextStyle(
                        fontFamily: 'kufi',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _searchCity() async {
    final city = _cityCtrl.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await geo.locationFromAddress(city);
      if (results.isNotEmpty) {
        final loc = results.first;
        await Get.find<QiblaController>().setManualLocation(
          loc.latitude,
          loc.longitude,
          address: city,
          locality: city,
        );
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() => _searchError = 'City not found');
      }
    } catch (e) {
      setState(
        () => _searchError = 'citySearchFailed'.tr.isEmpty
            ? 'Search failed. Check your internet connection.'
            : 'citySearchFailed'.tr,
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _applyManual() {
    if (!_formKey.currentState!.validate()) return;
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) return;

    Get.find<QiblaController>().setManualLocation(lat, lng);
    Navigator.of(context).pop();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color primary;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.primary,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontFamily: 'kufi', fontSize: 13, color: primary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'kufi',
          fontSize: 12,
          color: primary.withValues(alpha: 0.40),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SearchButton extends StatelessWidget {
  final bool isLoading;
  final Color primary;
  final VoidCallback onTap;

  const _SearchButton({
    required this.isLoading,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.search_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
