import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:karna_main/constents/colors.dart';
import 'package:karna_main/data/userdata.dart';
import 'package:karna_main/routes/routes_imports.gr.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class GetData extends StatefulWidget {
  const GetData({super.key});

  @override
  State<GetData> createState() => _GetDataState();
}

final UserData udata = Get.put(UserData());

class _GetDataState extends State<GetData> {
  Timer? timer;
  int secondsElapsed = 0;
  List keyvalue = [];
  List dbvalue = [];
  Future<void> getkey() async {
    String uri = "https://atrakarnaaapi.000webhostapp.com/update_bool.php";
    try {
      var res = await http.post(Uri.parse(uri), body: {"boolen": "true"});
      if (jsonEncode(res.body).isNotEmpty) {
        setState(() {
          keyvalue = jsonDecode(res.body);
          print(keyvalue);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getdb() async {
    String uri = "https://atrakarnaaapi.000webhostapp.com/getdbvalue.php";
    try {
      var res = await http.get(Uri.parse(uri));
      if (jsonEncode(res.body).isNotEmpty) {
        setState(() {
          dbvalue = jsonDecode(res.body);
          print(keyvalue);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    setState(() {
      getkey();
      getdb();
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        getdb();
        secondsElapsed++;
        if (secondsElapsed >= 10) {
          timer.cancel();
        }
      });
    });

    super.initState();
  }

  void dispose() {
    super.dispose();
    // Cancel the timer when the widget is disposed to prevent memory leaks
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: keyvalue.isEmpty ||
              dbvalue.isEmpty ||
              keyvalue[0]['Db-VALUE'] == dbvalue[0]['Db-VALUE']
          ? InkWell(
              onTap: () {
                setState(() {
                  getkey();
                  getdb();
                });
              },
              child: Center(
                  child: Lottie.asset('assets/loading.json',
                      repeat: true, reverse: false, height: 100, width: 100)),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Text(
                  dbvalue[0]["Db-VALUE"],
                  style: const TextStyle(color: Colors.white, fontSize: 45),
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      elevation: MaterialStatePropertyAll<double>(10),
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.white),
                    ),
                    onPressed: () {
                      udata.userDbvalue = dbvalue[0]["Db-VALUE"];
                      AutoRouter.of(context).push(const ToDataBaseRoute());
                    },
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
