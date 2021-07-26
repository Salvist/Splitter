
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:splitter_app/custom_widgets/dialog_split_info.dart';

import 'package:splitter_app/custom_widgets/gradient_container.dart';
import 'package:splitter_app/recent_split_data.dart';
import 'package:splitter_app/split/split_done.dart';
import 'package:splitter_app/splitter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'db_local.dart';
import 'theme.dart';
import 'split/split.dart';
import 'split_and_claim/bridge.dart';
import 'split_and_claim/host/split_host.dart';
import 'split_and_claim/join/split_join.dart';
import 'split_and_claim/host/split_and_claim.dart';
import 'split_and_claim/host/split_and_claim_done.dart';
import 'split_and_claim/join/split_join_done.dart';
import 'package:splitter_app/settings/settings.dart';
import 'settings/help.dart';
import 'settings/about.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  //runApp(Splitter());
  runApp(SplitterStateWidget(child: Splitter()));
}

//This is a data class
class SplitterState{
  final HistoryBloc bloc;
  SplitterState({
    @required this.bloc
  });
}

class SplitterStateScope extends InheritedWidget{
  final SplitterState data;
  SplitterStateScope(this.data, {Key key, @required Widget child}) : super(key: key, child: child);
  static SplitterState of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<SplitterStateScope>().data;
  }

  @override
  bool updateShouldNotify(SplitterStateScope oldWidget) => data != oldWidget.data;
}

class SplitterStateWidget extends StatefulWidget{
  final Widget child;
  SplitterStateWidget({@required this.child});

  static _SplitterStateWidget of(BuildContext context){
    return context.findAncestorStateOfType<_SplitterStateWidget>();
  }

  @override
  _SplitterStateWidget createState() => _SplitterStateWidget();
}

class _SplitterStateWidget extends State<SplitterStateWidget>{
  SplitterState _data = SplitterState(
    bloc: HistoryBloc(),
  );

  @override
  Widget build(BuildContext context){
    return SplitterStateScope(
      _data,
      child: widget.child
    );
  }
}


class Splitter extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splitter',
      theme: splitterTheme,
      initialRoute: '/',
      routes: {
        '/' : (context) => SplitterMainMenu(),
        '/split' : (context) => SplitMain(),
        '/splitclaimbridge' : (context) => SplitBridge(),
        '/splithost' : (context) => SplitHost(),
        '/splitjoin' : (context) => SplitJoin(),
        '/splitclaim' : (context) => SplitAndClaim(),
        '/splitclaimdone' : (context) => SplitClaimDone(),
        '/splitjoindone' : (context) => SplitJoinDone(),
        '/splitsettings' : (context) => SplitSettings(),
        '/splithelp' : (context) => SplitterHelp(),
        '/splitabout' : (context) => SplitterAbout(),
        '/splitdone' : (context) => SplitDone(),
      },
    );
  }
}

class SplitterMainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      body: GradientContainer(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AppTitle(),
                RecentSplits(),
                Menu(),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class AppTitle extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
              'Splitter',
              style: Theme.of(context).textTheme.headline1
          ),
          Text(
              'Split the bill equally!',
              style: Theme.of(context).textTheme.subtitle1
          ),
        ],
      ),
    );
  }
}

class RecentSplits extends StatefulWidget {
  @override
  _RecentSplits createState() => _RecentSplits();
}

class _RecentSplits extends State<RecentSplits>{
  Database localDatabase;
  

  Future<bool> showSplitInfo(int index, int length) async {
    index = index + length-1 + -2 * index;

    RecentSplitData recentSplitData = await DatabaseLocal.db.getSplitInfo(index);

    String title = recentSplitData.splitNote;
    String info = recentSplitData.showSplitInfo();

    //Split
    if(recentSplitData.type == 1){
      return showDialog(
        context: context,
        builder: (context) => new DialogSplitInfo(
          title: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
          content: Text(info, style: TextStyle(fontSize: 16, height: 1.5)),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          // backgroundColor: Colors.cyan[300],
        ),
      );
    }
    else if (recentSplitData.type == 2){
      //Split and Claim Host
      info += '\n\nParticipants:\n';
      List<Map<String, dynamic>> participants = await DatabaseLocal.db.getParticipants(index);
      participants.forEach((participant) {
        info += '${participant['participant_name']}: \$${participant['participant_bill']}\n';
      });

      return showDialog(
        context: context,
        builder: (context) => new DialogSplitInfo(
          title: Text('$title (Host)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
          content: Text(info, style: TextStyle(fontSize: 16, height: 1.5)),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          // backgroundColor: Colors.cyan[300],
        ),
      );
    }
    else {
      info += '\n\nPay to host: ';
      info += await DatabaseLocal.db.getHost(index);

      return showDialog(
        context: context,
        builder: (context) => new DialogSplitInfo(
          title: Text('$title (Join)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
          content: Text(info, style: TextStyle(fontSize: 16, height: 1.5)),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          // backgroundColor: Colors.cyan[300],
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect){
        return LinearGradient(
            begin: Alignment(0.0, 0.0),
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.transparent]
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(
          children: [
            Text('Recent Splits:', style: Theme.of(context).textTheme.subtitle1,),
            ConstrainedBox(
              constraints: BoxConstraints(
                  // maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.22
              ),
              child: StreamBuilder(
                stream: SplitterStateScope.of(context).bloc.recentSplits,
                builder: (context, AsyncSnapshot<List<RecentSplitData>> asyncSnapshot){
                  if(asyncSnapshot.hasData){
                    asyncSnapshot.data.forEach((element) {print(element.toString());});
                    if(asyncSnapshot.data.length != 0){
                      return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 0, bottom: 92),
                          itemCount: asyncSnapshot.data.length,
                          itemBuilder: (context, index){
                            return Card(
                              child: ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                onTap: (){showSplitInfo(index, asyncSnapshot.data.length);},
                                title: Text(asyncSnapshot.data[index].note,),
                                subtitle: Text(asyncSnapshot.data[index].date, style: TextStyle(color: Colors.white, fontSize: 14),),
                                trailing: Text('\$${asyncSnapshot.data[index].splitAmount.toStringAsFixed(2)}'),
                                // isThreeLine: true,
                              ),
                            );
                          });
                    }
                    else {
                      return Text('No recent splits.');
                    }
                  }
                  else {
                    return Text('Loading history...');
                  }

                },
              ),

            )
          ],
        ),
      ),
    );
  }
}

class Menu extends StatefulWidget {

  @override
  _Menu createState() => _Menu();
}

class _Menu extends State<Menu>{
  String administrativeArea = '';

  @override
  void initState(){
    super.initState();
    getPosition();
  }

  void getPosition() async {
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    List<Placemark> pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    Placemark place = pm[0];
    if(this.mounted)setState(() {
      administrativeArea = place.administrativeArea;
    });
  }

  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: (){
              Navigator.pushNamed(context, '/split',
                  arguments: administrativeArea);
            },
            child: Text('Split',
              style: Theme.of(context).textTheme.button
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: (){
              Navigator.pushNamed(context, '/splitclaimbridge', arguments: administrativeArea);
            },
            child: Text('Split & Claim',
              style: Theme.of(context).textTheme.button
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: (){
              Navigator.pushNamed(context, '/splitsettings',);
            },
            child: Text('Others',
              style: Theme.of(context).textTheme.button
            ),
          ),
        ],
      ),
    );
  }
}