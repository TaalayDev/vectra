// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'strings.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StringsEn extends Strings {
  StringsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vectra';

  @override
  String get uiFieldTap => 'Tap to edit';

  @override
  String get uiFieldEnabled => 'Enabled';

  @override
  String get uiFieldDisabled => 'Disabled';
}
