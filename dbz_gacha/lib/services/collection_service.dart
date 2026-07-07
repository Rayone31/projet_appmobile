import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CollectionService {
  static const String _fileName = 'unlocked_persos.json';

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Set<int>> loadUnlockedIds() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        await _saveUnlockedIds({});
        return {};
      }
      final content = await file.readAsString();
      final data = jsonDecode(content) as List;
      return data.map((id) => id as int).toSet();
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveUnlockedIds(Set<int> ids) async {
    final file = await _getLocalFile();
    await file.writeAsString(jsonEncode(ids.toList()));
  }

  Future<void> unlockPerso(int id) async {
    final ids = await loadUnlockedIds();
    ids.add(id);
    await _saveUnlockedIds(ids);
  }
}