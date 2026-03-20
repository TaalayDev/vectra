import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_provider.dart';

part 'recent_projects_provider.g.dart';

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

    final projects = <RecentProject>[];
    for (final file in files) {
      final stat = await file.stat();
      final name = file.path.split(Platform.pathSeparator).last.replaceAll('.vct', '');
      projects.add(RecentProject(
        filePath: file.path,
        name: name,
        modifiedAt: stat.modified,
        fileSize: stat.size,
      ));
    }
    return projects;
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
