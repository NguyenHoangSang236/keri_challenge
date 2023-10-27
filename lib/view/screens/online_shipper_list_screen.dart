import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/main.dart';
import 'package:keri_challenge/view/components/layout.dart';

@RoutePage()
class OnlineShipperScreen extends StatefulWidget {
  const OnlineShipperScreen({super.key});

  @override
  State<StatefulWidget> createState() => _OnlineShipperScreenState();
}

class _OnlineShipperScreenState extends State<OnlineShipperScreen> {
  final Stream<QuerySnapshot> _usersStream = fireStore
      .collection('users')
      .where('role', isEqualTo: 'shipper')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Shipper đang hoạt động',
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }

                return SizedBox(
                  height: 500.height,
                  child: ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs
                        .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['fullName']),
                            subtitle: Text(data['phoneNumber']),
                            trailing: Text(data['isOnline'].toString()),
                          );
                        })
                        .toList()
                        .cast(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
