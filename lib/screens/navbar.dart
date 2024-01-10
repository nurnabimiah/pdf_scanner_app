import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pw;

import 'home_screen.dart';
import 'myfiles_screen.dart';

class NavBar extends StatefulWidget {

  static const String routeName = '/navbar_route';
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {


  var tabIndex = 0;
  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _images = [];


  Future<void> getImageFromGallery() async {
    List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        // _images = pickedFiles.map((file) => File(file.path)).toList();
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    } else {
      print('No image selected');
    }
  }

  void createPDF() {
    for (var img in _images) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
        pageFormat: pw.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ));
    }
  }

  void savePDF() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/filename.pdf');
      await file.writeAsBytes(await pdf.save());
      showPrintedMessage(context, 'Success', 'Saved to documents');
    } catch (e) {
      showPrintedMessage(context, 'Error', e.toString());
    }
  }

  void showPrintedMessage(BuildContext context, String title, String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(msg),
              ],
            ),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: IndexedStack(index: tabIndex, children: const [
        HomeScreen(),
        MyfileScreen(),
      ]),
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 4,
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            currentIndex: tabIndex,
            onTap: changeTabIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey.shade300,
            items: [
              itemBar(
                Icons.home,
                "Home",
              ),
              itemBar(Icons.file_copy_sharp, "Files")
            ],
          )),


      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (builder) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.300,
                    child: Container(
                        decoration: new BoxDecoration(
                            color: Colors.white70.withOpacity(1),
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(40.0),
                                topRight: const Radius.circular(40.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            Text('Upload Files'),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Image.asset(
                                      'images/camera.png',
                                      height: 65,
                                      width: 70,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text('Take a Photo')
                                  ],
                                ),
                                SizedBox(
                                  width: 30,
                                ),

                                /// ...import files
                                GestureDetector(
                                  onTap: () {},
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/import_files.png',
                                        height: 65,
                                        width: 70,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text('Import Files'),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),

                                ///......Gallery...............................

                                GestureDetector(
                                  onTap: () {
                                    getImageFromGallery();
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/gallery.png',
                                        height: 65,
                                        width: 70,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text('Gallery')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),

                            // cross....
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'images/cancel.png',
                                height: 65,
                              ),
                            )
                          ],
                        )),
                  );
                });
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

itemBar(IconData icon, String label) {
  return BottomNavigationBarItem(
    icon: Icon(icon),
    label: label,
  );


}



// class HomeScreen extends StatefulWidget {
//   final List<File> images;
//   final ValueChanged<int> onTabChanged;
//
//   const HomeScreen({Key? key, required this.images, required this.onTabChanged})
//       : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(
//       length: 3,
//       vsync: this,
//       initialIndex: widget.images.isNotEmpty ? 0 : 1,
//     );
//   }
//
//   @override
//   void didUpdateWidget(covariant HomeScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     widget.onTabChanged(_tabController.index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Document Scanner"),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             tabs: [
//               Text('Doc pdf Scanner'),
//               Text('Id card Scanner'),
//               Text('Business Card Scanner'),
//             ],
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 Container(
//                   color: Colors.red,
//                   child: ListView.builder(
//                     itemCount: widget.images.length,
//                     itemBuilder: (context, index) {
//                       return Image.file(widget.images[index]);
//                     },
//                   ),
//                 ),
//                 Container(color: Colors.white),
//                 Container(color: Colors.white),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class NavBar extends StatefulWidget {
//   static const String routeName = '/navbar_route';
//
//   const NavBar({Key? key}) : super(key: key);
//
//   @override
//   State<NavBar> createState() => _NavBarState();
// }
//
// class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
//   var tabIndex = 0;
//   List<File> _images = [];
//   final picker = ImagePicker();
//   final pdf = pw.Document();
//
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//
//   void changeTabIndex(int index) {
//     setState(() {
//       tabIndex = index;
//     });
//     _tabController.index = index;
//   }
//
//   Future<void> getImageFromGallery() async {
//     List<XFile>? pickedFiles = await picker.pickMultiImage();
//     if (pickedFiles != null) {
//       setState(() {
//         _images.addAll(pickedFiles.map((file) => File(file.path)));
//       });
//     } else {
//       print('No image selected');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: HomeScreen(
//         images: _images,
//         onTabChanged: (index) {
//           setState(() {
//             tabIndex = index;
//           });
//         },
//       ),
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 4,
//         child: BottomNavigationBar(
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           selectedFontSize: 12,
//           currentIndex: tabIndex,
//           onTap: changeTabIndex,
//           selectedItemColor: Colors.blue,
//           unselectedItemColor: Colors.grey.shade300,
//           items: [
//             itemBar(Icons.home, "Home",),
//             itemBar(Icons.file_copy_sharp, "Files"),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blue,
//         child: Icon(Icons.add),
//         onPressed: () {
//           showModalBottomSheet(
//             backgroundColor: Colors.transparent,
//             context: context,
//             builder: (builder) {
//               return Container(
//                 height: MediaQuery.of(context).size.height * 0.300,
//                 child: Container(
//                   decoration: new BoxDecoration(
//                     color: Colors.white70.withOpacity(1),
//                     borderRadius: new BorderRadius.only(
//                       topLeft: const Radius.circular(40.0),
//                       topRight: const Radius.circular(40.0),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         height: 12,
//                       ),
//                       Text('Upload Files'),
//                       SizedBox(
//                         height: 16,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Column(
//                             children: [
//                               Image.asset(
//                                 'images/camera.png',
//                                 height: 65,
//                                 width: 70,
//                               ),
//                               SizedBox(
//                                 height: 8,
//                               ),
//                               Text('Take a Photo')
//                             ],
//                           ),
//                           SizedBox(
//                             width: 30,
//                           ),
//                           GestureDetector(
//                             onTap: () {},
//                             child: Column(
//                               children: [
//                                 Image.asset(
//                                   'images/import_files.png',
//                                   height: 65,
//                                   width: 70,
//                                 ),
//                                 SizedBox(
//                                   height: 8,
//                                 ),
//                                 Text('Import Files'),
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                             width: 30,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               getImageFromGallery();
//                             },
//                             child: Column(
//                               children: [
//                                 Image.asset(
//                                   'images/gallery.png',
//                                   height: 65,
//                                   width: 70,
//                                 ),
//                                 SizedBox(
//                                   height: 8,
//                                 ),
//                                 Text('Gallery')
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 12,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: Image.asset(
//                           'images/cancel.png',
//                           height: 65,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   BottomNavigationBarItem itemBar(IconData icon, String label) {
//     return BottomNavigationBarItem(
//       icon: Icon(icon),
//       label: label,
//     );
//   }
//
//
//
// }



