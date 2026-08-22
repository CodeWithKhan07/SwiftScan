import 'package:path/path.dart' as p;

extension PathPresentation on String {
  String get fileName => p.basename(this);
}
