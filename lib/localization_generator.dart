import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import 'src/const_generator.dart';

Builder constGeneratorBuilder(BuilderOptions options) =>
    SharedPartBuilder([ConstGenerator()], 'const');
