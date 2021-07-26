import 'package:flutter/material.dart';

class DialogSplitInfo extends StatelessWidget{
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  const DialogSplitInfo({
    Key key,
    @required this.title,
    @required this.content,
    @required this.actions
}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.blueAccent[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        // height: MediaQuery.of(context).size.height * 0.32,
        child: Wrap(

          children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                width: double.infinity,
                height: 40,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: title,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20, top: 8),
              child: content,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            )

          ],
        ),
      ),
    );
  }
}