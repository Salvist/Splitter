import 'dart:async';

import 'package:splitter_app/recent_split_data.dart';
import 'package:splitter_app/split_data.dart';

import 'db_local.dart';

class HistoryBloc{
  HistoryBloc(){
    getHistory();
  }

  final _historyController = StreamController<List<RecentSplitData>>.broadcast();
  Stream<List<RecentSplitData>> get recentSplits => _historyController.stream;

  void dispose() {
    _historyController.close();
  }

  Future<void> getHistory() async {
    _historyController.sink.add(await DatabaseLocal.db.getSplitterHistory());
  }

  Future<void> addHistory(dynamic data, int type) async {
    await DatabaseLocal.db.insertSplitData(data, type);
    await getHistory();
  }

  Future<void> deleteHistory() async {
    await DatabaseLocal.db.deleteDB();
    await getHistory();
  }
}