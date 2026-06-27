import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipe_button_widget/swipe_button_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SwipeButtonWidget(
              acceptPoitTransition: 0.7,
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(0),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  color: Color.fromRGBO(197, 197, 197, 0.25),
                  spreadRadius: 1.5,
                ),
              ],
              borderRadius: BorderRadius.circular(8),
              colorBeforeSwipe: Colors.white,
              colorAfterSwiped: Colors.white,
              height: 60,
              childBeforeSwipe: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red[900],
                ),
                width: 100,
                height: double.infinity,
                child: const Center(
                  child: Text(
                    '>>>',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.white),
                  ),
                ),
              ),
              childAfterSwiped: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red[900],
                ),
                width: 100,
                height: double.infinity,
                child: const Center(
                  child: Text(
                    '>>>',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.white),
                  ),
                ),
              ),
              leftChildren: const [
                Align(
                  alignment: Alignment(0.9, 0),
                  child: Text(
                    'Swip for confirmation',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.red),
                  ),
                )
              ],
              rightChildren: const [
                Align(
                  alignment: Alignment(-0.6, 0),
                  child: Text(
                    'Swip for arrived',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.red),
                  ),
                )
              ],
              onHorizontalDragUpdate: (e) {},
              onHorizontalDragRight: (e) {
                return areYouSureDialog(context);
              },
              onHorizontalDragleft: (e) async {
                return false;
              }),
          const SizedBox(height: 8),
          SwipeButtonWidget(
            padding: const EdgeInsets.all(15),
            borderRadius: BorderRadius.circular(8),
            childBeforeSwipe: Text(
              '>>> Slide To Logout',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(5, 132, 55, 1),
              ),
            ),
            childAfterSwiped: Text(
              '<<< Slide To Login',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            leftChildren: const [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Active',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
            rightChildren: const [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Offline',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
            onHorizontalDragUpdate: (e) {},
            onHorizontalDragRight: (e) {
              return areYouSureDialog(context);
            },
            onHorizontalDragleft: (e) {
              return areYouSureDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

Future<bool> areYouSureDialog(BuildContext context) async {
  bool isActive = false;
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      child: Container(
        color: Colors.white,
        height: 140,
        width: 150,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure?'),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    isActive = true;
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    isActive = false;
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return isActive;
}
