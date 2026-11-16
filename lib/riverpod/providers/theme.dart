import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kover/riverpod/repository/storage_repository.dart';
import 'package:kover/utils/instant_transition_builder.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/utils/logging.dart';
import 'package:kover/utils/theme.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

final CardThemeData cardThemeData = const CardThemeData();

final _theme = MaterialTheme(
  Typography.material2021().black,
);

final _lightBase = _theme.light().copyWith(
  colorScheme: _theme.light().colorScheme.copyWith(
    primary: const Color(0xff006b5f),
    primaryContainer: const Color(0xffb8eee3),
    onPrimaryContainer: const Color(0xff00372f),
    surface: const Color(0xfff8f6f1),
    surfaceContainerLowest: const Color(0xfff8f6f1),
    surfaceContainerLow: const Color(0xfff2f0eb),
    surfaceContainer: const Color(0xffeceae5),
    surfaceContainerHigh: const Color(0xffe6e4df),
  ),
  scaffoldBackgroundColor: const Color(0xfff8f6f1),
);
final _darkBase = _theme.dark().copyWith(
  colorScheme: _theme.dark().colorScheme.copyWith(
    primary: const Color(0xff83d8c7),
    primaryContainer: const Color(0xff205f56),
    onPrimaryContainer: const Color(0xffd8fff5),
    surface: const Color(0xff101412),
    surfaceDim: const Color(0xff101412),
    surfaceBright: const Color(0xff353a37),
    surfaceContainerLowest: const Color(0xff0b0f0d),
    surfaceContainerLow: const Color(0xff181c1a),
    surfaceContainer: const Color(0xff1d211f),
    surfaceContainerHigh: const Color(0xff272c29),
    surfaceContainerHighest: const Color(0xff323734),
  ),
  scaffoldBackgroundColor: const Color(0xff101412),
);

final _lightBorderSide = BorderSide(
  color: _lightBase.colorScheme.outline,
  width: 2.0,
);

final _darkBorderSide = BorderSide(
  color: _darkBase.colorScheme.outline,
  width: 2.0,
);

final _cardTheme = CardThemeData(
  elevation: 0,
  margin: EdgeInsets.zero,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(LayoutConstants.mediumBorderRadius),
  ),
);
final _outlinedLightCardTheme = _cardTheme.copyWith(
  shape: RoundedRectangleBorder(
    side: _lightBorderSide,
    borderRadius: BorderRadius.circular(12.0),
  ),
);

final _outlinedDarkCardTheme = _cardTheme.copyWith(
  shape: RoundedRectangleBorder(
    side: _darkBorderSide,
    borderRadius: BorderRadius.circular(12.0),
  ),
);

final _progressIndicatorTheme = const ProgressIndicatorThemeData(
  strokeCap: .round,
);

final _navigationBarTheme = NavigationBarThemeData(
  height: 72.0,
  elevation: 0,
  labelBehavior: .alwaysShow,
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(LayoutConstants.mediumBorderRadius),
  ),
);

final _segmentedButtonTheme = SegmentedButtonThemeData(
  style: SegmentedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        LayoutConstants.smallerBorderRadius,
      ),
    ),
  ),
);

final _inputDecorationTheme = const InputDecorationTheme(
  filled: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide.none,
  ),
  isDense: true,
);

final _reduceAnimationsPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    for (final platform in TargetPlatform.values)
      platform: const InstantPageTransitionsBuilder(),
  },
);

enum KoverThemeMode {
  light,
  dark,
  black,
  system,
}

@freezed
sealed class ThemeModel with _$ThemeModel {
  const ThemeModel._();
  const factory ThemeModel({
    @Default(KoverThemeMode.system) KoverThemeMode mode,
    @Default(false) bool outlined,
    @Default(false) bool reduceAnimations,
  }) = _ThemeModel;

  factory ThemeModel.fromJson(Map<String, Object?> json) =>
      _$ThemeModelFromJson(json);

  ThemeData get _lightTheme => _lightBase.copyWith(
    cardTheme: _cardTheme,
    sliderTheme: SliderThemeData(
      inactiveTrackColor: _lightBase.colorScheme.onSurface.withAlpha(0x55),
      inactiveTickMarkColor: _lightBase.colorScheme.onSurface,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _lightBase.colorScheme.surfaceContainer.withValues(
              alpha: 0.5,
            );
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _lightBase.colorScheme.onSurface.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
    ),
    progressIndicatorTheme: _progressIndicatorTheme,
    navigationBarTheme: _navigationBarTheme,
    segmentedButtonTheme: _segmentedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );

  ThemeData get _outlinedLightTheme => _lightTheme.copyWith(
    cardTheme: _outlinedLightCardTheme,
  );

  ThemeData get lightTheme {
    final theme = outlined ? _outlinedLightTheme : _lightTheme;
    return reduceAnimations
        ? theme.copyWith(
            pageTransitionsTheme: _reduceAnimationsPageTransitionsTheme,
          )
        : theme;
  }

  ThemeData get _darkTheme => _darkBase.copyWith(
    cardTheme: _cardTheme,
    sliderTheme: SliderThemeData(
      inactiveTrackColor: _darkBase.colorScheme.onSurface.withAlpha(0x55),
      inactiveTickMarkColor: _darkBase.colorScheme.onSurface,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _darkBase.colorScheme.surfaceContainer.withValues(
              alpha: 0.5,
            );
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _darkBase.colorScheme.onSurface.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
    ),
    progressIndicatorTheme: _progressIndicatorTheme,
    navigationBarTheme: _navigationBarTheme,
    segmentedButtonTheme: _segmentedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );

  ThemeData get _outlinedDarkTheme => _darkTheme.copyWith(
    cardTheme: _outlinedDarkCardTheme,
  );

  ThemeData get darkTheme {
    if (mode == .black) {
      return blackTheme;
    }

    final theme = outlined ? _outlinedDarkTheme : _darkTheme;
    return reduceAnimations
        ? theme.copyWith(
            pageTransitionsTheme: _reduceAnimationsPageTransitionsTheme,
          )
        : theme;
  }

  ThemeData get sepiaTheme {
    final sepiaScheme = _lightTheme.colorScheme.copyWith(
      surface: const Color(0xFFF4ECD8),
      surfaceDim: const Color(0xFFBFA06A),
      surfaceContainer: const Color(0xFFBFA06A),
      onSurface: const Color(0xFF3B2F1B),
    );

    final theme = _lightTheme.copyWith(
      colorScheme: sepiaScheme,
      scaffoldBackgroundColor: sepiaScheme.surface,
    );
    return reduceAnimations
        ? theme.copyWith(
            pageTransitionsTheme: _reduceAnimationsPageTransitionsTheme,
          )
        : theme;
  }

  ThemeData get blackTheme {
    final baseTheme = outlined ? _outlinedDarkTheme : _darkTheme;
    final blackScheme = baseTheme.colorScheme.copyWith(
      surface: const Color(0xff000000),
      surfaceDim: const Color(0xff000000),
      surfaceBright: const Color(0xff363a35),
      surfaceContainerLowest: const Color(0xff0b0f0b),
      surfaceContainerLow: const Color(0xff181d18),
      surfaceContainer: const Color(0xff1c211c),
      surfaceContainerHigh: const Color(0xff262b26),
      surfaceContainerHighest: const Color(0xff313631),
      onSurface: const Color(0xffdfe4dc),
      onSurfaceVariant: const Color(0xffc0c9c1),
      outline: const Color(0xff8a938c),
      outlineVariant: const Color(0xff404943),
    );
    final theme = baseTheme.copyWith(
      colorScheme: blackScheme,
      scaffoldBackgroundColor: blackScheme.surface,
    );
    return reduceAnimations
        ? theme.copyWith(
            pageTransitionsTheme: _reduceAnimationsPageTransitionsTheme,
          )
        : theme;
  }

  ThemeData get theme {
    return switch (mode) {
      .light => lightTheme,
      .dark => darkTheme,
      .black => blackTheme,
      .system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness == .dark
            ? darkTheme
            : lightTheme,
    };
  }
}

@riverpod
@JsonPersist()
class Theme extends _$Theme {
  @override
  Future<ThemeModel> build() async {
    await persist(
      ref.watch(storageProvider.future),
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
    ).future;

    return state.value ?? const ThemeModel();
  }

  Future<void> setMode(KoverThemeMode mode) async {
    final current = await future;

    state = AsyncData(current.copyWith(mode: mode));
    log.info(
      'set theme mode',
      attributes: {'value': mode},
    );
  }

  Future<void> setOutlined(bool value) async {
    final current = await future;

    state = AsyncData(current.copyWith(outlined: value));
    log.info(
      'set outlined theme',
      attributes: {'value': value},
    );
  }

  Future<void> setReduceAnimations(bool value) async {
    final current = await future;

    state = AsyncData(current.copyWith(reduceAnimations: value));
    log.info(
      'set reduce animations',
      attributes: {'value': value},
    );
  }

  void reset() {
    state = const AsyncData(ThemeModel());
    log.info('reset theme to default');
  }
}
