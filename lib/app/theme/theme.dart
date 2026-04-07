import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../core/utils/local_storage.dart';
import 'art_deco.dart';
import 'art_nouevau.dart';
import 'autumn_harvest.dart';
import 'cherry_blossom.dart';
import 'candy_carnival.dart';
import 'copper_steampunk.dart';
import 'coral_reef.dart';
import 'cosmic.dart';
import 'crystaline.dart';
import 'cyberpunk.dart';
import 'dark.dart';
import 'data_stream.dart';
import 'enchanted_forest.dart';
import 'forest.dart';
import 'golden_hour.dart';
import 'gothic_theme.dart';
import 'ice_crystal.dart';
import 'light.dart';
import 'lofi_night.dart';
import 'midnight.dart';
import 'monochrome.dart';
import 'neon.dart';
import 'ocean.dart';
import 'origami.dart';
import 'pastel.dart';
import 'pointillism.dart';
import 'prismatic.dart';
import 'purple_rain.dart';
import 'retro_wave.dart';
import 'rose_quartz_garden.dart';
import 'stained_glass.dart';
import 'steampunk.dart';
import 'sunset.dart';
import 'theme_type.dart';

import 'arctic_aurora.dart';
import 'deep_sea.dart';
import 'dream_scape.dart';
import 'toxic_waste.dart';
import 'volcanic.dart';
import 'emerald_forest.dart';
import 'winter_wonderland.dart';
import 'halloween.dart';
import 'bioluminescent_brutalism.dart';

export 'theme_type.dart';

@immutable
class AppThemeRadii {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  const AppThemeRadii({this.xs = 4, this.sm = 8, this.md = 12, this.lg = 16, this.xl = 24, this.pill = 999});

  BorderRadius get extraSmall => BorderRadius.circular(xs);
  BorderRadius get small => BorderRadius.circular(sm);
  BorderRadius get medium => BorderRadius.circular(md);
  BorderRadius get large => BorderRadius.circular(lg);
  BorderRadius get extraLarge => BorderRadius.circular(xl);
  BorderRadius get full => BorderRadius.circular(pill);

  AppThemeRadii copyWith({double? xs, double? sm, double? md, double? lg, double? xl, double? pill}) {
    return AppThemeRadii(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      pill: pill ?? this.pill,
    );
  }

  static AppThemeRadii lerp(AppThemeRadii a, AppThemeRadii b, double t) {
    return AppThemeRadii(
      xs: lerpDouble(a.xs, b.xs, t) ?? a.xs,
      sm: lerpDouble(a.sm, b.sm, t) ?? a.sm,
      md: lerpDouble(a.md, b.md, t) ?? a.md,
      lg: lerpDouble(a.lg, b.lg, t) ?? a.lg,
      xl: lerpDouble(a.xl, b.xl, t) ?? a.xl,
      pill: lerpDouble(a.pill, b.pill, t) ?? a.pill,
    );
  }
}

@immutable
class AppThemeSizes {
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double iconSm;
  final double iconMd;
  final double iconLg;
  final double buttonHeight;
  final double minButtonWidth;
  final double inputHeight;
  final double toolbarHeight;
  final double cardElevation;

  const AppThemeSizes({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 20,
    this.xl = 24,
    this.xxl = 32,
    this.iconSm = 16,
    this.iconMd = 20,
    this.iconLg = 24,
    this.buttonHeight = 44,
    this.minButtonWidth = 88,
    this.inputHeight = 48,
    this.toolbarHeight = kToolbarHeight,
    this.cardElevation = 2,
  });

  AppThemeSizes copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? iconSm,
    double? iconMd,
    double? iconLg,
    double? buttonHeight,
    double? minButtonWidth,
    double? inputHeight,
    double? toolbarHeight,
    double? cardElevation,
  }) {
    return AppThemeSizes(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconLg: iconLg ?? this.iconLg,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      minButtonWidth: minButtonWidth ?? this.minButtonWidth,
      inputHeight: inputHeight ?? this.inputHeight,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      cardElevation: cardElevation ?? this.cardElevation,
    );
  }

  static AppThemeSizes lerp(AppThemeSizes a, AppThemeSizes b, double t) {
    return AppThemeSizes(
      xxs: lerpDouble(a.xxs, b.xxs, t) ?? a.xxs,
      xs: lerpDouble(a.xs, b.xs, t) ?? a.xs,
      sm: lerpDouble(a.sm, b.sm, t) ?? a.sm,
      md: lerpDouble(a.md, b.md, t) ?? a.md,
      lg: lerpDouble(a.lg, b.lg, t) ?? a.lg,
      xl: lerpDouble(a.xl, b.xl, t) ?? a.xl,
      xxl: lerpDouble(a.xxl, b.xxl, t) ?? a.xxl,
      iconSm: lerpDouble(a.iconSm, b.iconSm, t) ?? a.iconSm,
      iconMd: lerpDouble(a.iconMd, b.iconMd, t) ?? a.iconMd,
      iconLg: lerpDouble(a.iconLg, b.iconLg, t) ?? a.iconLg,
      buttonHeight: lerpDouble(a.buttonHeight, b.buttonHeight, t) ?? a.buttonHeight,
      minButtonWidth: lerpDouble(a.minButtonWidth, b.minButtonWidth, t) ?? a.minButtonWidth,
      inputHeight: lerpDouble(a.inputHeight, b.inputHeight, t) ?? a.inputHeight,
      toolbarHeight: lerpDouble(a.toolbarHeight, b.toolbarHeight, t) ?? a.toolbarHeight,
      cardElevation: lerpDouble(a.cardElevation, b.cardElevation, t) ?? a.cardElevation,
    );
  }
}

@immutable
class AppThemeBorders {
  final double thin;
  final double regular;
  final double thick;
  final double focus;

  const AppThemeBorders({this.thin = 1, this.regular = 1.25, this.thick = 2, this.focus = 2});

  BorderSide side(Color color, {double? width}) {
    return BorderSide(color: color, width: width ?? regular);
  }

  AppThemeBorders copyWith({double? thin, double? regular, double? thick, double? focus}) {
    return AppThemeBorders(
      thin: thin ?? this.thin,
      regular: regular ?? this.regular,
      thick: thick ?? this.thick,
      focus: focus ?? this.focus,
    );
  }

  static AppThemeBorders lerp(AppThemeBorders a, AppThemeBorders b, double t) {
    return AppThemeBorders(
      thin: lerpDouble(a.thin, b.thin, t) ?? a.thin,
      regular: lerpDouble(a.regular, b.regular, t) ?? a.regular,
      thick: lerpDouble(a.thick, b.thick, t) ?? a.thick,
      focus: lerpDouble(a.focus, b.focus, t) ?? a.focus,
    );
  }
}

@immutable
class AppButtonThemeTokens {
  final EdgeInsetsGeometry padding;
  final Size minimumSize;
  final double elevation;
  final double iconSize;

  const AppButtonThemeTokens({
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.minimumSize = const Size(88, 44),
    this.elevation = 0,
    this.iconSize = 20,
  });

  AppButtonThemeTokens copyWith({EdgeInsetsGeometry? padding, Size? minimumSize, double? elevation, double? iconSize}) {
    return AppButtonThemeTokens(
      padding: padding ?? this.padding,
      minimumSize: minimumSize ?? this.minimumSize,
      elevation: elevation ?? this.elevation,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  static AppButtonThemeTokens lerp(AppButtonThemeTokens a, AppButtonThemeTokens b, double t) {
    return AppButtonThemeTokens(
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t) ?? a.padding,
      minimumSize: Size.lerp(a.minimumSize, b.minimumSize, t) ?? a.minimumSize,
      elevation: lerpDouble(a.elevation, b.elevation, t) ?? a.elevation,
      iconSize: lerpDouble(a.iconSize, b.iconSize, t) ?? a.iconSize,
    );
  }
}

@immutable
class AppInputThemeTokens {
  final EdgeInsetsGeometry contentPadding;
  final bool filled;
  final bool isDense;

  const AppInputThemeTokens({
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.filled = true,
    this.isDense = false,
  });

  AppInputThemeTokens copyWith({EdgeInsetsGeometry? contentPadding, bool? filled, bool? isDense}) {
    return AppInputThemeTokens(
      contentPadding: contentPadding ?? this.contentPadding,
      filled: filled ?? this.filled,
      isDense: isDense ?? this.isDense,
    );
  }

  static AppInputThemeTokens lerp(AppInputThemeTokens a, AppInputThemeTokens b, double t) {
    return AppInputThemeTokens(
      contentPadding: EdgeInsetsGeometry.lerp(a.contentPadding, b.contentPadding, t) ?? a.contentPadding,
      filled: t < 0.5 ? a.filled : b.filled,
      isDense: t < 0.5 ? a.isDense : b.isDense,
    );
  }
}

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  final AppThemeRadii radii;
  final AppThemeSizes sizes;
  final AppThemeBorders borders;
  final AppButtonThemeTokens buttons;
  final AppInputThemeTokens inputs;

  const AppThemeTokens({
    this.radii = const AppThemeRadii(),
    this.sizes = const AppThemeSizes(),
    this.borders = const AppThemeBorders(),
    this.buttons = const AppButtonThemeTokens(),
    this.inputs = const AppInputThemeTokens(),
  });

  @override
  AppThemeTokens copyWith({
    AppThemeRadii? radii,
    AppThemeSizes? sizes,
    AppThemeBorders? borders,
    AppButtonThemeTokens? buttons,
    AppInputThemeTokens? inputs,
  }) {
    return AppThemeTokens(
      radii: radii ?? this.radii,
      sizes: sizes ?? this.sizes,
      borders: borders ?? this.borders,
      buttons: buttons ?? this.buttons,
      inputs: inputs ?? this.inputs,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      radii: AppThemeRadii.lerp(radii, other.radii, t),
      sizes: AppThemeSizes.lerp(sizes, other.sizes, t),
      borders: AppThemeBorders.lerp(borders, other.borders, t),
      buttons: AppButtonThemeTokens.lerp(buttons, other.buttons, t),
      inputs: AppInputThemeTokens.lerp(inputs, other.inputs, t),
    );
  }
}

class AppTheme {
  static const defaultType = ThemeType.retroWave;
  static final defaultTheme = AppTheme.fromType(defaultType);

  final ThemeType type;
  final bool isDark;

  // Primary colors
  final Color primaryColor;
  final Color primaryVariant;
  final Color onPrimary;

  // Secondary colors
  final Color accentColor;
  final Color onAccent;

  // Background colors
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  // UI element colors
  final Color divider;
  final Color toolbarColor;
  final Color error;
  final Color success;
  final Color warning;

  // Grid colors
  final Color gridLine;
  final Color gridBackground;

  // Canvas-related colors
  final Color canvasBackground;
  final Color selectionOutline;
  final Color selectionFill;

  // Icon colors
  final Color activeIcon;
  final Color inactiveIcon;

  // Font settings
  final TextTheme textTheme;
  final FontWeight primaryFontWeight;

  // Shared design tokens
  final AppThemeTokens tokens;

  AppTheme({
    required this.type,
    required this.isDark,
    required this.primaryColor,
    required this.primaryVariant,
    required this.onPrimary,
    required this.accentColor,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.divider,
    required this.toolbarColor,
    required this.error,
    required this.success,
    required this.warning,
    required this.gridLine,
    required this.gridBackground,
    required this.canvasBackground,
    required this.selectionOutline,
    required this.selectionFill,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.textTheme,
    required this.primaryFontWeight,
    this.tokens = const AppThemeTokens(),
  });

  AppThemeRadii get radii => tokens.radii;
  AppThemeSizes get sizes => tokens.sizes;
  AppThemeBorders get borders => tokens.borders;
  AppButtonThemeTokens get buttons => tokens.buttons;
  AppInputThemeTokens get inputs => tokens.inputs;

  AppTheme copyWith({
    ThemeType? type,
    bool? isDark,
    Color? primaryColor,
    Color? primaryVariant,
    Color? onPrimary,
    Color? accentColor,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? divider,
    Color? toolbarColor,
    Color? error,
    Color? success,
    Color? warning,
    Color? gridLine,
    Color? gridBackground,
    Color? canvasBackground,
    Color? selectionOutline,
    Color? selectionFill,
    Color? activeIcon,
    Color? inactiveIcon,
    TextTheme? textTheme,
    FontWeight? primaryFontWeight,
    AppThemeTokens? tokens,
  }) {
    return AppTheme(
      type: type ?? this.type,
      isDark: isDark ?? this.isDark,
      primaryColor: primaryColor ?? this.primaryColor,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      onPrimary: onPrimary ?? this.onPrimary,
      accentColor: accentColor ?? this.accentColor,
      onAccent: onAccent ?? this.onAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      divider: divider ?? this.divider,
      toolbarColor: toolbarColor ?? this.toolbarColor,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      gridLine: gridLine ?? this.gridLine,
      gridBackground: gridBackground ?? this.gridBackground,
      canvasBackground: canvasBackground ?? this.canvasBackground,
      selectionOutline: selectionOutline ?? this.selectionOutline,
      selectionFill: selectionFill ?? this.selectionFill,
      activeIcon: activeIcon ?? this.activeIcon,
      inactiveIcon: inactiveIcon ?? this.inactiveIcon,
      textTheme: textTheme ?? this.textTheme,
      primaryFontWeight: primaryFontWeight ?? this.primaryFontWeight,
      tokens: tokens ?? this.tokens,
    );
  }

  factory AppTheme.fromType(ThemeType type) {
    switch (type) {
      case ThemeType.lightMode:
        return buildLightTheme();
      case ThemeType.darkMode:
        return buildDarkTheme();
      case ThemeType.midnight:
        return buildMidnightTheme();
      case ThemeType.forest:
        return buildForestTheme();
      case ThemeType.sunset:
        return buildSunsetTheme();
      case ThemeType.ocean:
        return buildOceanTheme();
      case ThemeType.monochrome:
        return buildMonochromeTheme();
      case ThemeType.neon:
        return buildNeonTheme();
      case ThemeType.cosmic:
        return buildCosmicTheme();
      case ThemeType.pastel:
        return buildPastelTheme();
      case ThemeType.purpleRain:
        return buildPurpleRainTheme();
      case ThemeType.goldenHour:
        return buildGoldenHourTheme();
      case ThemeType.cyberpunk:
        return buildCyberpunkTheme();
      case ThemeType.cherryBlossom:
        return buildCherryBlossomTheme();
      case ThemeType.retroWave:
        return buildRetroWaveTheme();
      case ThemeType.iceCrystal:
        return buildIceCrystalTheme();
      case ThemeType.volcanic:
        return buildVolcanicTheme();
      case ThemeType.arcticAurora:
        return buildArcticAuroraTheme();
      case ThemeType.toxicWaste:
        return buildToxicWasteTheme();
      case ThemeType.dreamscape:
        return buildDreamscapeTheme();
      case ThemeType.deepSea:
        return buildDeepSeaTheme();
      case ThemeType.copperSteampunk:
        return buildCopperSteampunkTheme();
      case ThemeType.prismatic:
        return buildPrismaticTheme();
      case ThemeType.emeraldForest:
        return buildEmeraldForestTheme();
      case ThemeType.roseQuartzGarden:
        return buildRoseQuartzGardenTheme();
      case ThemeType.winterWonderland:
        return buildWinterWonderlandTheme();
      case ThemeType.autumnHarvest:
        return buildAutumnHarvestTheme();
      case ThemeType.halloween:
        return buildHalloweenTheme();
      case ThemeType.steampunk:
        return buildSteampunkTheme();
      case ThemeType.gothic:
        return buildGothicTheme();
      case ThemeType.artDeco:
        return buildArtDecoTheme();
      case ThemeType.crystalline:
        return buildCrystallineTheme();
      case ThemeType.enchantedForest:
        return buildEnchantedForestTheme();
      case ThemeType.coralReef:
        return buildCoralReefTheme();
      case ThemeType.stainedGlass:
        return buildStainedGlassTheme();
      case ThemeType.dataStream:
        return buildDataStreamTheme();
      case ThemeType.lofiNight:
        return buildLofiNightTheme();
      case ThemeType.artNouveau:
        return buildArtNouveauTheme();
      case ThemeType.origami:
        return buildOrigamiTheme();
      case ThemeType.pointillism:
        return buildPointillismTheme();
      case ThemeType.candyCarnival:
        return buildCandyCarnivalTheme();
      case ThemeType.bioluminescentBrutalism:
        return buildBioluminescentBrutalismTheme();
    }
  }

  ThemeData get themeData {
    OutlineInputBorder inputBorder(Color color, {double? width}) {
      return OutlineInputBorder(
        borderSide: borders.side(color, width: width),
        borderRadius: radii.medium,
      );
    }

    final buttonShape = RoundedRectangleBorder(borderRadius: radii.medium);
    final surfaceStroke = borders.side(divider.withValues(alpha: isDark ? 0.45 : 0.75), width: borders.thin);

    return ThemeData(
      useMaterial3: true,
      extensions: [tokens],
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimary,
        secondary: accentColor,
        onSecondary: onAccent,
        error: error,
        onError: isDark ? Colors.black : Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider, thickness: borders.thin, space: sizes.md),
      textTheme: textTheme,
      iconTheme: IconThemeData(color: activeIcon, size: sizes.iconLg),
      appBarTheme: AppBarTheme(
        backgroundColor: toolbarColor,
        foregroundColor: textPrimary,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: sizes.toolbarHeight,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: primaryFontWeight),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: radii.large, side: surfaceStroke),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: textPrimary),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        textStyle: TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: radii.medium, side: surfaceStroke),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radii.lg)),
          side: surfaceStroke,
        ),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(color: toolbarColor),
      cardTheme: CardThemeData(
        color: surface,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        surfaceTintColor: surface,
        elevation: sizes.cardElevation,
        margin: EdgeInsets.all(sizes.xs),
        shape: RoundedRectangleBorder(borderRadius: radii.large, side: surfaceStroke),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: surfaceVariant,
        filled: inputs.filled,
        isDense: inputs.isDense,
        contentPadding: inputs.contentPadding,
        constraints: BoxConstraints(minHeight: sizes.inputHeight),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textDisabled),
        helperStyle: TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        enabledBorder: inputBorder(divider, width: borders.regular),
        focusedBorder: inputBorder(primaryColor, width: borders.focus),
        errorBorder: inputBorder(error, width: borders.regular),
        focusedErrorBorder: inputBorder(error, width: borders.focus),
        disabledBorder: inputBorder(divider.withValues(alpha: 0.55), width: borders.thin),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: onPrimary,
          backgroundColor: primaryColor,
          minimumSize: buttons.minimumSize,
          elevation: buttons.elevation,
          padding: buttons.padding,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: primaryFontWeight),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: buttons.minimumSize,
          padding: buttons.padding,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: primaryFontWeight),
          shape: buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: onPrimary,
          backgroundColor: primaryColor,
          minimumSize: buttons.minimumSize,
          padding: buttons.padding,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: primaryFontWeight),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: buttons.minimumSize,
          side: borders.side(primaryColor, width: borders.regular),
          padding: buttons.padding,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: primaryFontWeight),
          shape: buttonShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: activeIcon,
          iconSize: buttons.iconSize,
          minimumSize: Size(sizes.buttonHeight, sizes.buttonHeight),
          padding: EdgeInsets.all(sizes.xs),
          shape: buttonShape,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: buttons.elevation,
        shape: RoundedRectangleBorder(borderRadius: radii.large),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: radii.medium, side: surfaceStroke),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withValues(alpha: 0.3),
        thumbColor: onPrimary,
        overlayColor: primaryColor.withValues(alpha: 0.12),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: radii.small),
        side: borders.side(divider),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        }),
        checkColor: WidgetStateProperty.all(onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        }),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        }),
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return onPrimary;
          }
          return isDark ? Colors.grey.shade200 : Colors.white;
        }),
      ),
    );
  }

  Color shift(Color c, double amount) {
    amount *= (isDark ? -1 : 1);

    /// Convert to HSL
    var hslc = HSLColor.fromColor(c);

    /// Add/Remove lightness
    double lightness = (hslc.lightness + amount).clamp(0, 1.0).toDouble();

    /// Convert back to Color
    return hslc.withLightness(lightness).toColor();
  }
}

extension BuildContextAppThemeX on BuildContext {
  AppThemeTokens get themeTokens => Theme.of(this).extension<AppThemeTokens>() ?? const AppThemeTokens();
}

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'app_theme';
  AppTheme _currentTheme = AppTheme.defaultTheme;

  AppTheme get theme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = LocalStorage();
    final themeString = prefs.getString(_themeKey);

    if (themeString != null) {
      try {
        final themeType = ThemeType.values.firstWhere(
          (t) => t.toString() == themeString,
          orElse: () => ThemeType.darkMode,
        );
        _currentTheme = AppTheme.fromType(themeType);
        notifyListeners();
      } catch (e) {
        // If theme loading fails, use default
        _currentTheme = AppTheme.defaultTheme;
      }
    }
  }

  Future<void> setTheme(ThemeType themeType) async {
    _currentTheme = AppTheme.fromType(themeType);

    final prefs = LocalStorage();
    prefs.setString(_themeKey, themeType.toString());

    notifyListeners();
  }
}
