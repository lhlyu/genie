## 0.0.1

🎉 初始版本发布 / Initial Release

- 支持从模板目录递归生成文件与目录结构
- 自动渲染路径与文件内容中的变量（如 `{{name.camelCase}}`）
- 内置多种命名转换工具：`snakeCase`、`upperSnakeCase`、`camelCase`、`pascalCase`、`kebabCase`
- 支持跳过指定文件（如 `.gitkeep`）与模板后缀剥离
- 简洁 API：`Genie.generate(src, dst, name)` 一步生成完整模块结构
