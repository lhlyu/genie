# Genie

[![pub package](https://img.shields.io/pub/v/genie?label=genie)](https://pub.dev/packages/genie)
![Last Commit](https://img.shields.io/github/last-commit/lhlyu/genie)

> 基于模板的 Dart 代码生成工具库  
> A template-based code generation library for Dart.

## 📦 安装

- `dart`

```shell
dart pub add genie
```

- `flutter`

```shell
flutter pub add genie
```


## 🚀 使用方法

### 1️⃣ 准备模板目录

假设你的模板目录结构如下：

```
templates/
 └── feature/
     ├── {{name.snakeCase}}/
     │   ├── {{name.snakeCase}}_page.dart.template
     └── .gitkeep
```

模板文件内容示例（`{{name.snakeCase}}_page.dart.template`）：

```dart
import 'package:flutter/material.dart';

class {{name.pascalCase}}Page extends StatelessWidget {
  const {{name.pascalCase}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('{{name.upperSnakeCase}} Page')),
    );
  }
}
```


### 2️⃣ 代码中生成模块

```dart
import 'package:genie/genie.dart';

void main() {
  Genie.generate(
    'templates/feature',     // 模板目录
    'lib/src/features',      // 生成目标目录
    'userProfile',           // 模块名
	useNameForDir: true,     // 使用模块名作为目录
  );
}
```

执行后会在 `lib/src/features/` 下生成：

```
lib/src/features/
 └── user_profile/
     ├── user_profile_page.dart
```

## 🧠 支持的模板变量

| 变量名                       | 示例输入 (`userProfile`) | 说明 / Description |
|---------------------------|----------------------|------------------|
| `{{name}}`                | userProfile          | 原始名称             |
| `{{name.snakeCase}}`      | user_profile         | 下划线命名            |
| `{{name.upperSnakeCase}}` | USER_PROFILE         | 全大写下划线命名         |
| `{{name.camelCase}}`      | userProfile          | 小驼峰命名            |
| `{{name.pascalCase}}`     | UserProfile          | 大驼峰命名            |
| `{{name.kebabCase}}`      | user-profile         | 中划线命名            |

你可以在模板文件名和文件内容中自由使用这些变量。
Genie 会自动渲染路径和文件内容。

## ⚙️ 可选参数

```dart
Genie.generate(
  src,  // 模板目录
  dst,  // 目标目录
  name, // 模块名
  useNameForDir: false,        // 使用模块名作为目录
  templateSuffix: '.template', // 模板文件后缀（默认 .template）
  skipFileNames: ['.gitkeep'], // 跳过的文件
);
```

---

## 🧱 文件渲染规则

* 所有路径与文件内容均支持 `{{variable}}` 替换
* 模板文件后缀（默认为 `.template`）会自动移除
* 已存在的文件不会被覆盖
* 会自动递归创建目录结构
