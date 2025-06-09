import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../modal/category.dart';
import '../../service/auth/auth_service.dart';
import '../../service/user/firebase_cloud_storage.dart';
import '../../service/user/user.dart';
import '../../utils/constants/size.dart';
import 'dart:typed_data';

class StudentIdScreen extends StatefulWidget {
  const StudentIdScreen({super.key, required this.userEmail});
  final String userEmail;

  @override
  State<StudentIdScreen> createState() => _StudentIdScreenState();
}

class _StudentIdScreenState extends State<StudentIdScreen> {
  late final FirebaseCloudStorage _userInfoService;

  late Stream<UserInfo?> _stream;
  bool _isVertical = false;
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    _userInfoService = FirebaseCloudStorage();
    _stream = _userInfoService.fetchUserInfoStreamByEmail(widget.userEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: Text(
          'Student ID Card',
          style: Theme.of(
            context,
          ).textTheme.titleLarge,
        )),
        body: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.waiting:
                if (snapshot.hasData) {
                  final userInfo = snapshot.data;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Container()),
                          RepaintBoundary(
                            key: _widgetKey,
                            child: Container(
                              padding: const EdgeInsets.all(TSizes.md),
                              height: TSizes.buttomWidth,
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return _StudentIdCard(
                                    userInfo: userInfo,
                                    isVertical: _isVertical,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 10);
                                },
                                itemCount: 1,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                          Expanded(child: Container()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      const Color(0xFF0E131D)),
                                  side: WidgetStateProperty.all(
                                    const BorderSide(
                                      color: Color(0xFF0E131D),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isVertical = !_isVertical;
                                  });
                                },
                                child: const Text("Rotate Card"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      const Color(0xFF0E131D)),
                                  side: WidgetStateProperty.all(
                                    const BorderSide(
                                      color: Color(0xFF0E131D),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  await _captureAndSave(context);
                                },
                                child: const Text("Download Card"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }

  Future<void> _captureAndSave(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary = _widgetKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 10.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = (await getApplicationDocumentsDirectory()).path;
      final file = File(
          '$directory/STUDENT_ID-${DateTime.now().millisecondsSinceEpoch}.png');
      var name = await file.writeAsBytes(pngBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved successfully ${name.toString()}'),
          ),
        );
      }
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception(e);
    }
  }
}

Future<Category?> fetchCategoryById(String id) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection("categories").doc(id).get();

    if (doc.exists) {
      return Category.fromMap(doc.id, doc.data()!);
    } else {
      print("No category found with the provided ID.");
      return null;
    }
  } catch (e) {
    print("Error fetching category by ID: $e");
    return null;
  }
}

class _StudentIdCard extends StatelessWidget {
  final UserInfo? userInfo;
  final bool isVertical;
  const _StudentIdCard({required this.userInfo, required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: isVertical ? 0 : -90 * 3.14159 / 180,
      child: Container(
        width: 350,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffdae3f4)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: userInfo?.imageUrl_ != null &&
                        userInfo!.imageUrl_!.isNotEmpty
                    ? Image.network(userInfo!.imageUrl_!,
                        width: 70, height: 70, fit: BoxFit.cover)
                    : Image.asset('assets/logos/logo.jpeg',
                        width: 70, height: 70, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Name:',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${userInfo?.firstName_ ?? ''} ${userInfo?.surname_ ?? ''}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cohort:',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    FutureBuilder<Category?>(
                      future: fetchCategoryById(userInfo?.program ?? ""),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Text('Not found');
                        } else {
                          final category = snapshot.data!;
                          return Text(
                            category.name,
                            style: Theme.of(context).textTheme.labelMedium,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Year:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      userInfo?.year.toString() ?? "",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Student ID:',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      userInfo?.id.toString() ?? '',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
