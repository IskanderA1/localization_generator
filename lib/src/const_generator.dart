import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:localization_generator/src/constant_model.dart';

import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

class ConstGenerator extends Generator {
  static String dirPath = 'assets/localization/';

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    var buffer = StringBuffer();

    final List<ConstantModel> constants = [];
    final response = await getAllConstants();
    constants.addAll(response);

    return generateClass(buffer, constants);
  }

  Future<List<ConstantModel>> getAllConstants() async {
    final localizationDir = Directory(dirPath).listSync()
      ..removeWhere((element) => element.path.contains('.'));

    final List<ConstantModel> constantsList = [];
    for (var element in localizationDir) {
      final langDirName = element.path.split('/').last;
      final localizationDir = Directory('$dirPath$langDirName/').listSync();
      for (var element in localizationDir) {
        final file = await File(element.path).readAsString();
        final fileName = element.path.split('/').last.split('_').first;
        Map<String, dynamic> data = json.decode(file);
        constantsList.addAll(
          data.keys.map((key) => ConstantModel(key, fileName, langDirName)),
        );
      }
    }
    return constantsList;
  }

  List<String> checkConstants(
    String value,
    List<ConstantModel> constants,
  ) {
    List<String> result = [];
    List<String> allLangDirNames = constants.map((e) => e.langDirName).toList();
    allLangDirNames.removeDuplicates();
    if (allLangDirNames.isNotEmpty) {
      allLangDirNames.forEach(
        (langDir) {
          final constantsFromLangDir = constants
              .where(
                (constant) => constant.langDirName == langDir,
              )
              .map((constant) => constant.key);
          if (!constantsFromLangDir.contains(value)) {
            result.add(langDir);
          }
        },
      );
    }
    return result;
  }

  String generateClass(
    StringBuffer buffer,
    List<ConstantModel> constants,
  ) {
    List<String> filesName = constants.map((e) => e.fileName).toList();
    filesName.removeDuplicates();

    if (filesName.isNotEmpty) {
      buffer.writeln(
        '''/// Сгенерированные константы ключей для языковых словарей из
            /// assets/localization/{langCode}
          /// *************************************************************************''',
      );
    } else {
      buffer.writeln(
        '''/// Не найдены языковые файлы .json
          /// в папке assets/localization/{langCode}
          /// *************************************************************************''',
      );
    }
    filesName.forEach((fileName) {
      final className = '${fileName[0].toUpperCase()}${fileName.substring(1)}';
      final List<String> constantsValue = constants
          .where((constant) => constant.fileName == fileName)
          .map((constant) => constant.key)
          .toList();
      constantsValue.removeDuplicates();

      buffer.writeln('''class SRLocalization$className{''');
      buffer.writeln('''SRLocalization$className._();\n''');
      for (var item in constantsValue) {
        if (filesName.length > 1) {
          var missingLanguages = checkConstants(item, constants);
          buffer.writeln(
            '''static const String ${getConstNameFromJsonKey(item)} = '$item'; ${missingLanguages.isNotEmpty ? '//TODO: Отсуствует ключ для языков: $missingLanguages' : ''}\n''',
          );
        } else {
          buffer.writeln(
            '''static const String ${getConstNameFromJsonKey(item)} = '$item';\n\n''',
          );
        }
      }
      buffer.writeln('''}\n''');
    });
    return buffer.toString();
  }

  String getConstNameFromJsonKey(String jsonKey) {
    List<String> temp = jsonKey.split('_');
    String result = '';
    temp.forEach((element) {
      if (element == temp.first) {
        result = element;
      } else {
        result += '${element[0].toUpperCase()}${element.substring(1)}';
      }
    });
    return result;
  }
}
