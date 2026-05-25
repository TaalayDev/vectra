import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/utils/local_storage.dart';
import 'document_provider.dart';

part 'recent_projects_provider.g.dart';

const _kMaxTrackedPaths = 20;

class RecentProject {
  final String filePath;
  final String name;
  final DateTime modifiedAt;
  final int fileSize;

  const RecentProject({
    required this.filePath,
    required this.name,
    required this.modifiedAt,
    required this.fileSize,
  });
}

@riverpod
class RecentProjects extends _$RecentProjects {
  @override
  Future<List<RecentProject>> build() async {
    return _loadProjects();
  }

  Future<List<RecentProject>> _loadProjects() async {
    final repo = ref.read(vecFileRepositoryProvider);
    final dir = await repo.getDefaultSaveDirectory();
    final files = await repo.listProjectFiles(dir);

    final seen = <String>{};
    final projects = <RecentProject>[];

    Future<void> addFile(File file) async {
      if (seen.contains(file.path)) return;
      if (!await file.exists()) return;
      seen.add(file.path);
      final stat = await file.stat();
      final name = file.path.split(Platform.pathSeparator).last.replaceAll('.vct', '');
      projects.add(RecentProject(
        filePath: file.path,
        name: name,
        modifiedAt: stat.modified,
        fileSize: stat.size,
      ));
    }

    for (final file in files) {
      await addFile(file);
    }

    // Merge externally-tracked paths (from iCloud Drive or other directories)
    final tracked = LocalStorage.instance.getStringList(StorageKey.recentOpenedPaths.name) ?? [];
    for (final path in tracked) {
      await addFile(File(path));
    }

    projects.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return projects;
  }

  Future<void> trackFilePath(String path) async {
    final key = StorageKey.recentOpenedPaths.name;
    final current = LocalStorage.instance.getStringList(key) ?? [];
    final updated = [path, ...current.where((p) => p != path)].take(_kMaxTrackedPaths).toList();
    LocalStorage.instance.setStringList(key, updated);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadProjects());
  }

  Future<void> deleteProject(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    await refresh();
  }
}
