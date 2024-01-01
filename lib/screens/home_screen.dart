import 'package:flutter/material.dart';

import '../reusable_widget/app_headertext_widget.dart';
import '../reusable_widget/reusable_appbar.dart';


import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document Scanner"),
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Text('Doc pdf Scanner'),
              Text('Id card Scanner'),
              Text('Business Card Scanner'),

            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(color: Colors.red), // Replace with your content for the first tab
                Container(color: Colors.green), // Replace with your content for the second tab
                Container(color: Colors.blue), // Replace with your content for the third tab
              ],
            ),
          ),
        ],
      ),
    );
  }
}

