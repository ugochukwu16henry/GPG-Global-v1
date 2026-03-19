import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global theme mode for the app (used by dark-mode toggle UI).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

