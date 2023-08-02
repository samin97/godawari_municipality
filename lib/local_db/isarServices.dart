import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'entities/offline_yojana_list.dart';
import 'entities/yojana_draft.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> saveYojanaDraft(YojanaDraft newYojana) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.yojanaDrafts.putSync(newYojana));
    print('draft saved');
  }

  Future<void> saveOfflineYojanas(OfflineYojana newOfflineYojana) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.offlineYojanas.putSync(newOfflineYojana));
  }

  Future<List<YojanaDraft>> getAllYojanaDetails() async {
    final isar = await db;
    return await isar.yojanaDrafts.where().findAll();
  }

  Future<List<OfflineYojana>> getAllOfflineYojanaDetails() async {
    final isar = await db;
    return await isar.offlineYojanas.where().findAll();
  }

  Stream<List<YojanaDraft>> listenToYojana() async* {
    final isar = await db;
    yield* isar.yojanaDrafts.where().watch(fireImmediately: true);
  }

  Stream<List<OfflineYojana>> listenToOfflineYojana() async* {
    final isar = await db;
    yield* isar.offlineYojanas.where().watch(fireImmediately: true);
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<void> deleteDraft(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.yojanaDrafts.delete(id);
      print('draft deleted : $success');
    });
  }

  Future<void> deleteAllDraft() async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success =
          await isar.yojanaDrafts.filter().idGreaterThan(-1).deleteAll();
      print('Yojana deleted : $success');
    });
  }

  Future<void> deleteAllOfflineYojana() async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success =
          await isar.offlineYojanas.filter().idGreaterThan(-1).deleteAll();
      print('Yojana deleted : $success');
    });
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [YojanaDraftSchema, OfflineYojanaSchema],
        inspector: true,
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
