import 'package:genie/genie.dart';

const templateDir = './example/template';

const outDir = './dist';

void main() {
  final name = 'demo';

  Genie.generate(templateDir, outDir, name);
}
