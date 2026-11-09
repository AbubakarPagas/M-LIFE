// ── Direction page ────────────────────────────────────────────────────────────
// This file now redirects to the full QiblaPage implementation.
// It is kept here so that the existing route '/direction' and all references
// to `Direction` continue to compile unchanged.

import 'package:flutter/material.dart';
import 'package:misbah_path/presentation/pages/qibla/presentation/qibla_page.dart';

export 'package:misbah_path/presentation/pages/qibla/presentation/qibla_page.dart';

/// Thin wrapper kept for backward-compatibility with the route table.
class Direction extends StatelessWidget {
  const Direction({super.key});

  @override
  Widget build(BuildContext context) => const QiblaPage();
}
