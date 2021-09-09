import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import 'src/const_generator.dart';

Builder constGeneratorBuilder(BuilderOptions options) => PartBuilder(
      [ConstGenerator()],
      '.const.dart',
      header: '''
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// Автомтический сгенерированный код классов с константами
    ''',
    );
