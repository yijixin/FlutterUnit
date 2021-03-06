
import 'package:sqflite/sqflite.dart';

import '../app_storage.dart';
import '../po/category_po.dart';


//"""
// CREATE TABLE IF NOT EXISTS category(
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     name VARCHAR(64) NOT NULL,
//     color VARCHAR(9) DEFAULT '#FF2196F3',
//     info VARCHAR(256) DEFAULT '这里什么都没有...',
//     created DATETIME NOT NULL,
//     updated DATETIME NOT NULL,
//     priority INTEGER DEFAULT 0,
//     image VARCHAR(128) NULL image DEFAULT ''
//     );
//""";

class CategoryDao {
  final  AppStorage storage;

  CategoryDao(this.storage);

  Future<Database> get _db async =>await storage.db;


  Future<int> insert(CategoryPo widget) async {
    //插入方法
    final db = await _db;
    String addSql = //插入数据
        "INSERT INTO "
        "category(name,color,info,priority,image,created,updated) "
        "VALUES (?,?,?,?,?,?,?);";
    return await db.transaction((tran) async => await tran.rawInsert(addSql, [
          widget.name,
          widget.color,
          widget.info,
          widget.priority,
          widget.image,
          widget.created.toIso8601String(),
          widget.updated.toIso8601String(),
        ]));
  }

  Future<int> addWidget(int categoryId,int widgetId,) async {
    //插入方法
    final db = await _db;
    String addSql = //插入数据
        "INSERT INTO "
        "category_widget(widgetId,categoryId) "
        "VALUES (?,?);";
    return await db.transaction((tran) async => await tran.rawInsert(addSql, [
      widgetId,
      categoryId,
    ]));
  }


  Future<bool> existByName(String name) async {
    final db = await _db;
    String sql = //插入数据
        "SELECT COUNT(name) as count FROM category "
        "WHERE name = ?";
    var rawData = await db.rawQuery(sql, [name]);
    if (rawData.length > 0) {
      return rawData[0]['count'] > 0;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    //插入方法
    final db = await _db;
    return await db.rawQuery("SELECT * "
        "FROM category ORDER BY priority DESC,created DESC");
  }

  Future<void> deleteCollect(int id) async {
    //插入方法
    final db = await _db;
    return await db.execute(
        "DELETE FROM category "
            "WHERE id = ?",
        [id]);
  }

  Future<int> removeWidget(int categoryId, int widgetId) async {
    //插入方法
    final db = await _db;
    String deleteSql = //插入数据
        "DELETE FROM "
        "category_widget WHERE categoryId = ? AND widgetId = ? ";
    return await db
        .transaction((tran) async => await tran.rawInsert(deleteSql, [
      categoryId,
      widgetId,
    ]));
  }

  Future<bool> existWidgetInCollect(int categoryId, int widgetId) async {
    final db = await _db;
    String sql = //插入数据
        "SELECT COUNT(id) as count FROM category_widget "
        "WHERE categoryId = ? AND widgetId = ?";
    var rawData = await db.rawQuery(sql, [categoryId, widgetId]);
    if (rawData.length > 0) {
      return rawData[0]['count'] > 0;
    }
    return false;
  }

  Future<void> toggleCollect(int categoryId, int widgetId) async {
    if (await existWidgetInCollect(categoryId, widgetId)) {
      //已存在: 移除
      await removeWidget(categoryId, widgetId);
    } else {
      await addWidget(categoryId, widgetId);
    }
  }

  Future<void> toggleCollectDefault(int widgetId) async {
    await toggleCollect(1, widgetId);
  }

  Future<List<Map<String, dynamic>>> loadCollectWidgets(int categoryId) async{
    String querySql = //插入数据
        "SELECT * FROM widget "
        "WHERE id IN (SELECT widgetId FROM category_widget WHERE categoryId = ?)";

    final db = await _db;
    return await db.rawQuery(querySql,[categoryId]);

  }
}
