import 'package:Prism/routes/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

final Firestore databaseReference = Firestore.instance;
List prismWalls;
List subPrismWalls;
Map wall;
int page = 1;
Future<List> getPrismWalls() async {
  if (navStack.last == "Home") {
    final box = Hive.box('wallpapers');
    if ((box.get('wallpapers') == null) ||
        (box.get('wallpapers').toString() == "[]" || box.get('date') == null)) {
      debugPrint("Refetching whole collection");
      // toasts.error("Refetching whole collection");
      prismWalls = [];
      subPrismWalls = [];
      await databaseReference
          .collection("walls")
          .where('review', isEqualTo: true)
          .orderBy("createdAt", descending: true)
          .getDocuments()
          .then((value) {
        prismWalls = [];
        for (final f in value.documents) {
          Map<String, dynamic> map;
          map = f.data;
          map['createdAt'] = map['createdAt'].toString();
          prismWalls.add(map);
        }
        box.delete('wallpapers');
        if (prismWalls != []) {
          box.put('wallpapers', prismWalls);
          debugPrint("Wallpapers saved");
          box.put(
            'date',
            DateFormat("yy-MM-dd").format(
              DateTime.now(),
            ),
          );
          // box.put(
          //   'dateTime',
          //   DateTime.now().toString(),
          // );
          debugPrint(prismWalls.length.toString());
          subPrismWalls = box.get('wallpapers').sublist(0, 24) as List;
        } else {
          debugPrint("Not connected to Internet");
          subPrismWalls = [];
        }
      }).catchError((e) {
        debugPrint(e.toString());
        debugPrint("data done with error");
      });
    }
    // else if (box.get('date') !=
    //     DateFormat("yy-MM-dd").format(
    //       DateTime.now(),
    //     )) {
    //   debugPrint("Refetching part of collection");
    //   toasts.error("Refetching part of collection");
    //   prismWalls = [];
    //   subPrismWalls = [];
    //   final prevWalls = box.get('wallpapers') as List;
    //   for (final wall in prevWalls) {
    //     // if (DateTime.parse(wall['createdAt'].toString())
    //     //         .compareTo(DateTime.now()) <
    //     //     0) {
    //     prismWalls.add(wall);
    //     // }
    //   }
    //   await databaseReference
    //       .collection("walls")
    //       .where('review', isEqualTo: true)
    //       .orderBy("createdAt", descending: true)
    //       .where('createdAt',
    //           isGreaterThan: DateTime.parse(box.get('dateTime').toString()))
    //       .getDocuments()
    //       .then((value) {
    //     debugPrint(value.documents.length.toString());
    //     for (final f in value.documents) {
    //       Map<String, dynamic> map;
    //       map = f.data;
    //       map['createdAt'] = map['createdAt'].toString();
    //       prismWalls.add(map);
    //     }
    //   });
    //   box.delete('wallpapers');
    //   if (prismWalls != []) {
    //     box.put('wallpapers', prismWalls);
    //     debugPrint("New Wallpapers saved");
    //     box.put(
    //       'date',
    // DateFormat("yy-MM-dd").format(
    //   DateTime.now(),
    // ),
    //     );
    // box.put(
    //   'dateTime',
    //   DateTime.now().toString(),
    // );
    //     debugPrint(prismWalls.length.toString());
    //     subPrismWalls = box.get('wallpapers').sublist(0, 24) as List;
    //   } else {
    //     debugPrint("Not connected to Internet");
    //     subPrismWalls = [];
    //   }
    // }
    else {
      debugPrint("Community : Data Fetched from cache");
      // toasts.error("Data fetched from cache");
      prismWalls = [];
      subPrismWalls = [];
      prismWalls = box.get('wallpapers') as List;
      subPrismWalls = prismWalls.sublist(0, 24);
    }
  } else {
    debugPrint("Refresh blocked");
  }
  return subPrismWalls;
}

List seeMorePrism() {
  final int len = prismWalls.length;
  final double pages = len / 24;
  debugPrint(len.toString());
  debugPrint(pages.toString());
  debugPrint(page.toString());
  if (page < pages.floor()) {
    subPrismWalls.addAll(
        prismWalls.sublist(subPrismWalls.length, subPrismWalls.length + 24));
    page += 1;
  } else {
    subPrismWalls.addAll(prismWalls.sublist(subPrismWalls.length));
  }
  return subPrismWalls;
}

Future<Map> getDataByID(String id) async {
  wall = null;
  await databaseReference.collection("walls").getDocuments().then((value) {
    for (final element in value.documents) {
      if (element.data["id"] == id) {
        wall = element.data;
      }
    }
    return wall;
  });
}
