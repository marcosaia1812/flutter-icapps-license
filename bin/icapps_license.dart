import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import 'src/model/dto/dependency.dart';
import 'src/extension/string_builder_extension.dart';
import 'src/params.dart';

const baseUrl = 'https://pub.dev/api/packages/';
const urlVersionPath = '/versions/';
const licensePath = '/blob/master/LICENSE';

final outputFilePath = join('pubspec_licenses.txt');

Future<void> main(List<String> args) async {
  final pubspecYaml = File(join(Directory.current.path, 'pubspec.yaml'));
  if (!pubspecYaml.existsSync()) {
    throw Exception(
        'This program should be run from the root of a flutter/dart project');
  }

  final pubspecContent = pubspecYaml.readAsStringSync();
  final params = Params();
  await params.init(pubspecContent);

  final sb = StringBuffer();

  final outputFile = File(outputFilePath);
  if (!outputFile.existsSync()) {
    outputFile.createSync(recursive: true);
  }

  final nullableFieldInfix = params.nullSafe ? '?' : '';

  params.dependencies.forEach((e) {
    sb.write(_getDependencyText(e));
  });

  params.devDependencies.forEach((e) {
    sb.write(_getDependencyText(e));
  });

  outputFile.writeAsStringSync(sb.toString());

  Params.missingLicensesList.forEach(print);
  if (params.failFast &&
      Params.missingLicensesList.isNotEmpty &&
      Params.missingLicenses) {
    throw Exception('Failed to resolve all licenses');
  }
  print('DONE');
}

String _getDependencyText(Dependency dependency) {
  final sb = StringBuffer()
    ..writelnWithQuotesOrNull('Name', dependency.name)
    ..writelnWithQuotesOrNull('Version', dependency.version)
    ..writelnWithQuotesOrNull('License URL', dependency.licenseUrl)
    ..writeln(
        '\n\n${dependency.license}\n//-------------------------------------------------------------\n');
  return sb.toString();
}
