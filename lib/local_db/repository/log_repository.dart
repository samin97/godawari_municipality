
import '../../models/local_storage_model.dart';
import '../db/sqlite_db.dart';

class LogRepository{
  static var dbObject;

  static init(){
    dbObject = SqliteMethods();
    SqliteMethods().init();
  }
  static addLogs(Log log) => SqliteMethods().addLogs(log);

  static deleteLogs(String? attendDateTime) => dbObject.deleteLogs(attendDateTime);

  static getLogs() => dbObject.getLogs();

  static close() => dbObject.close();

}