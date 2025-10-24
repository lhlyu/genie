import 'dart:io';

import 'package:path/path.dart';

/// Genie 工具类 —— 用于模板渲染与命名转换
/// Genie Utility - Provides template rendering and naming style conversions.
class Genie {
  /// 将 [s] 转换为 snake_case（小写下划线分隔）
  /// Convert [s] to snake_case.
  static String snakeCase(String s) {
    return s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}').toLowerCase();
  }

  /// 将 [s] 转换为 UPPER_SNAKE_CASE（全大写下划线分隔）
  /// Convert [s] to UPPER_SNAKE_CASE (all caps with underscores).
  ///
  /// 示例 / Example:
  /// ```dart
  /// upperSnakeCase('userName');    // USER_NAME
  /// upperSnakeCase('UserProfile'); // USER_PROFILE
  /// ```
  static String upperSnakeCase(String s) {
    final snake = s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}');
    return snake.replaceAll(RegExp(r'[-\s]+'), '_').toUpperCase();
  }

  /// 将 [s] 转换为 PascalCase（大驼峰命名）
  /// Convert [s] to PascalCase.
  static String pascalCase(String s) {
    if (s.isEmpty) return s;
    s = s.replaceAll(RegExp(r'[_\-]+'), ' ');
    final parts = s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    return parts.map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase()).join();
  }

  /// 将 [s] 转换为 camelCase（小驼峰命名）
  /// Convert [s] to camelCase.
  static String camelCase(String s) {
    s = s.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    final parts = s.split(RegExp(r'\s+'));
    if (parts.isEmpty) return s;

    final first = parts.first.toLowerCase();
    final rest = parts.skip(1).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join();

    return '$first$rest';
  }

  /// 将 [s] 转换为 kebab-case（短横线分隔命名）
  /// Convert [s] to kebab-case.
  static String kebabCase(String s) {
    return s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}-${m[2]}').toLowerCase();
  }

  /// 根据 [name] 生成所有常见命名风格的映射表
  /// Build a map containing various naming style conversions for [name].
  static Map<String, String> buildVars(String name) {
    final s = snakeCase(name);
    final u = upperSnakeCase(name);
    final p = pascalCase(name);
    final c = camelCase(name);
    final k = kebabCase(name);
    return {
      'name': name,
      'name.snakeCase': s,
      'name.upperSnakeCase': u,
      'name.pascalCase': p,
      'name.camelCase': c,
      'name.kebabCase': k,
    };
  }

  /// 渲染模板字符串
  /// Render a template string by replacing placeholders with variable values.
  ///
  /// 支持占位符格式：`{{key}}` 或 `{{name.filter}}`
  /// Supported placeholders: `{{key}}` or `{{name.filter}}`
  static String render(String tpl, Map<String, String> vars) {
    return tpl.replaceAllMapped(RegExp(r'\{\{(name(?:\.\w+)?)\}\}'), (m) => vars[m[1]] ?? m[0]!);
  }

  /// 若 [str] 以 [suffix] 结尾，则移除该后缀；否则原样返回。
  /// Remove [suffix] from the end of [str] if present; otherwise return [str].
  static String stripSuffix(String str, String suffix) {
    if (suffix.isEmpty) return str;
    return str.endsWith(suffix) ? str.substring(0, str.length - suffix.length) : str;
  }

  /// 递归复制模板目录到目标目录，并进行变量渲染。
  /// Recursively copy and render template files from [src] to [dst].
  ///
  /// - 模板路径与内容均会被渲染（`{{var}}` 替换）
  /// - 已存在文件不会被覆盖
  /// - 会自动创建目录结构
  ///
  /// 参数 / Parameters:
  /// - [src] 模板源目录
  /// - [dst] 目标目录
  /// - [name] 模块名称，用于变量替换
  /// - [useNameForDir] 使用name作为目录（默认 `false`）
  /// - [templateSuffix] 模板文件后缀（默认 `.template`）
  /// - [skipFileNames] 要跳过的文件名（不会复制）
  static void generate(
    String src,
    String dst,
    String name, {
    bool useNameForDir = false,
    String templateSuffix = '.template',
    List<String> skipFileNames = const ['.gitkeep'],
  }) {
    final vars = buildVars(name);

    final srcDir = Directory(src);

    if (!srcDir.existsSync()) {
      throw Exception('模板目录不存在: $src');
    }

    if (useNameForDir) {
      dst = join(dst, name);
    }

    for (final entity in srcDir.listSync(recursive: true)) {
      final rel = relative(entity.path, from: srcDir.path);
      var newRel = render(rel, vars);
      newRel = stripSuffix(newRel, templateSuffix);

      final fileName = basename(newRel);

      if (entity is File && skipFileNames.contains(fileName)) {
        continue;
      }

      // 处理目录 / Process directory
      if (entity is Directory) {
        final targetDir = Directory(join(dst, newRel));
        targetDir.createSync(recursive: true);
        continue;
      }

      // 处理文件 / Process file
      final targetFile = File(join(dst, newRel));
      targetFile.parent.createSync(recursive: true);

      // 已存在则跳过 / Skip existing files
      if (targetFile.existsSync()) continue;

      final content = (entity as File).readAsStringSync();
      targetFile.writeAsStringSync(render(content, vars));
    }
  }
}
