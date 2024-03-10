import "package:flutter/material.dart";

class NHVMaterialTheme {
  final TextTheme textTheme;

  const NHVMaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4287646277),
      surfaceTint: Color(4287646277),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4294957782),
      onPrimaryContainer: Color(4282059016),
      secondary: Color(4287384160),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294957538),
      onSecondaryContainer: Color(4281992989),
      tertiary: Color(4278216820),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4288606205),
      onTertiaryContainer: Color(4278198052),
      error: Color(4287646277),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282059016),
      background: Color(4294965495),
      onBackground: Color(4280490264),
      surface: Color(4294965495),
      onSurface: Color(4280490264),
      surfaceVariant: Color(4294303195),
      onSurfaceVariant: Color(4283646786),
      outline: Color(4286935921),
      outlineVariant: Color(4292395711),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281937453),
      inverseOnSurface: Color(4294962667),
      inversePrimary: Color(4294947757),
      primaryFixed: Color(4294957782),
      onPrimaryFixed: Color(4282059016),
      primaryFixedDim: Color(4294947757),
      onPrimaryFixedVariant: Color(4285739823),
      secondaryFixed: Color(4294957538),
      onSecondaryFixed: Color(4281992989),
      secondaryFixedDim: Color(4294947272),
      onSecondaryFixedVariant: Color(4285543240),
      tertiaryFixed: Color(4288606205),
      onTertiaryFixed: Color(4278198052),
      tertiaryFixedDim: Color(4286764000),
      onTertiaryFixedVariant: Color(4278210392),
      surfaceDim: Color(4293449428),
      surfaceBright: Color(4294965495),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963439),
      surfaceContainer: Color(4294765288),
      surfaceContainerHigh: Color(4294370530),
      surfaceContainerHighest: Color(4294041308),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4285411372),
      surfaceTint: Color(4287646277),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4289355610),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4285214532),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4289027958),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278209107),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280647820),
      onTertiaryContainer: Color(4294967295),
      error: Color(4285411372),
      onError: Color(4294967295),
      errorContainer: Color(4289355610),
      onErrorContainer: Color(4294967295),
      background: Color(4294965495),
      onBackground: Color(4280490264),
      surface: Color(4294965495),
      onSurface: Color(4280490264),
      surfaceVariant: Color(4294303195),
      onSurfaceVariant: Color(4283318078),
      outline: Color(4285291353),
      outlineVariant: Color(4287198837),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281937453),
      inverseOnSurface: Color(4294962667),
      inversePrimary: Color(4294947757),
      primaryFixed: Color(4289355610),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4287449155),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4289027958),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4287186782),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4280647820),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278216305),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293449428),
      surfaceBright: Color(4294965495),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963439),
      surfaceContainer: Color(4294765288),
      surfaceContainerHigh: Color(4294370530),
      surfaceContainerHighest: Color(4294041308),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4282650638),
      surfaceTint: Color(4287646277),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4285411372),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282519076),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285214532),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278200108),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4278209107),
      onTertiaryContainer: Color(4294967295),
      error: Color(4282650638),
      onError: Color(4294967295),
      errorContainer: Color(4285411372),
      onErrorContainer: Color(4294967295),
      background: Color(4294965495),
      onBackground: Color(4280490264),
      surface: Color(4294965495),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4294303195),
      onSurfaceVariant: Color(4281213216),
      outline: Color(4283318078),
      outlineVariant: Color(4283318078),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281937453),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4294961124),
      primaryFixed: Color(4285411372),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4283570711),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285214532),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283439406),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4278209107),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278202936),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293449428),
      surfaceBright: Color(4294965495),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963439),
      surfaceContainer: Color(4294765288),
      surfaceContainerHigh: Color(4294370530),
      surfaceContainerHighest: Color(4294041308),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294947757),
      surfaceTint: Color(4294947757),
      onPrimary: Color(4283899419),
      primaryContainer: Color(4285739823),
      onPrimaryContainer: Color(4294957782),
      secondary: Color(4294947272),
      onSecondary: Color(4283702578),
      secondaryContainer: Color(4285543240),
      onSecondaryContainer: Color(4294957538),
      tertiary: Color(4286764000),
      onTertiary: Color(4278203965),
      tertiaryContainer: Color(4278210392),
      onTertiaryContainer: Color(4288606205),
      error: Color(4294947757),
      onError: Color(4283899419),
      errorContainer: Color(4285739823),
      onErrorContainer: Color(4294957782),
      background: Color(4279898384),
      onBackground: Color(4294041308),
      surface: Color(4279898384),
      onSurface: Color(4294041308),
      surfaceVariant: Color(4283646786),
      onSurfaceVariant: Color(4292395711),
      outline: Color(4288711818),
      outlineVariant: Color(4283646786),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4294041308),
      inverseOnSurface: Color(4281937453),
      inversePrimary: Color(4287646277),
      primaryFixed: Color(4294957782),
      onPrimaryFixed: Color(4282059016),
      primaryFixedDim: Color(4294947757),
      onPrimaryFixedVariant: Color(4285739823),
      secondaryFixed: Color(4294957538),
      onSecondaryFixed: Color(4281992989),
      secondaryFixedDim: Color(4294947272),
      onSecondaryFixedVariant: Color(4285543240),
      tertiaryFixed: Color(4288606205),
      onTertiaryFixed: Color(4278198052),
      tertiaryFixedDim: Color(4286764000),
      onTertiaryFixedVariant: Color(4278210392),
      surfaceDim: Color(4279898384),
      surfaceBright: Color(4282529589),
      surfaceContainerLowest: Color(4279503883),
      surfaceContainerLow: Color(4280490264),
      surfaceContainer: Color(4280753436),
      surfaceContainerHigh: Color(4281477159),
      surfaceContainerHighest: Color(4282200625),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294949299),
      surfaceTint: Color(4294947757),
      onPrimary: Color(4281533445),
      primaryContainer: Color(4291591028),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294948812),
      onSecondary: Color(4281532952),
      secondaryContainer: Color(4291197842),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4287027173),
      onTertiary: Color(4278196765),
      tertiaryContainer: Color(4283014313),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949299),
      onError: Color(4281533445),
      errorContainer: Color(4291591028),
      onErrorContainer: Color(4278190080),
      background: Color(4279898384),
      onBackground: Color(4294041308),
      surface: Color(4279898384),
      onSurface: Color(4294965753),
      surfaceVariant: Color(4283646786),
      onSurfaceVariant: Color(4292658883),
      outline: Color(4289961628),
      outlineVariant: Color(4287790973),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4294041308),
      inverseOnSurface: Color(4281477159),
      inversePrimary: Color(4285805616),
      primaryFixed: Color(4294957782),
      onPrimaryFixed: Color(4281073922),
      primaryFixedDim: Color(4294947757),
      onPrimaryFixedVariant: Color(4284359456),
      secondaryFixed: Color(4294957538),
      onSecondaryFixed: Color(4281008146),
      secondaryFixedDim: Color(4294947272),
      onSecondaryFixedVariant: Color(4284162616),
      tertiaryFixed: Color(4288606205),
      onTertiaryFixed: Color(4278195223),
      tertiaryFixedDim: Color(4286764000),
      onTertiaryFixedVariant: Color(4278205508),
      surfaceDim: Color(4279898384),
      surfaceBright: Color(4282529589),
      surfaceContainerLowest: Color(4279503883),
      surfaceContainerLow: Color(4280490264),
      surfaceContainer: Color(4280753436),
      surfaceContainerHigh: Color(4281477159),
      surfaceContainerHighest: Color(4282200625),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294965753),
      surfaceTint: Color(4294947757),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4294949299),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294965753),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4294948812),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294049279),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4287027173),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949299),
      onErrorContainer: Color(4278190080),
      background: Color(4279898384),
      onBackground: Color(4294041308),
      surface: Color(4279898384),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4283646786),
      onSurfaceVariant: Color(4294965753),
      outline: Color(4292658883),
      outlineVariant: Color(4292658883),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4294041308),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4283307797),
      primaryFixed: Color(4294959325),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4294949299),
      onPrimaryFixedVariant: Color(4281533445),
      secondaryFixed: Color(4294959078),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4294948812),
      onSecondaryFixedVariant: Color(4281532952),
      tertiaryFixed: Color(4289393663),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4287027173),
      onTertiaryFixedVariant: Color(4278196765),
      surfaceDim: Color(4279898384),
      surfaceBright: Color(4282529589),
      surfaceContainerLowest: Color(4279503883),
      surfaceContainerLow: Color(4280490264),
      surfaceContainer: Color(4280753436),
      surfaceContainerHigh: Color(4281477159),
      surfaceContainerHighest: Color(4282200625),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
