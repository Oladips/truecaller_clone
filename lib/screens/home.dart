// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_typing_uninitialized_variables

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truecaller_clone/components/custom_text.dart';
import 'package:truecaller_clone/cubit/dashboard_cubit.dart';
import 'package:truecaller_clone/models/contact_entity.dart';
import 'package:truecaller_clone/objectbox.g.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final PageController pageController = PageController();
  late final AnimationController animationController;
  List<Contact>? contactList;

  List<Contacts>? conts;

  late Store _store;
  bool isInitialized = false;

  late Contacts _contact;

  late Stream<List<Contacts>> _stream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<DashboardCubit>().favoritesPressed();
      contactsInit();
    });
    getApplicationDocumentsDirectory().then((dir) {
      _store = Store(
        getObjectBoxModel(),
        directory: "${dir.path}/contacts",
      );

      setState(() {
        _stream = _store
            .box<Contacts>()
            .query()
            .watch(triggerImmediately: true)
            .map((event) => event.find());
        isInitialized = true;
      });
    });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 250,
      ),
    );
    scrollController.addListener(() {
      setState(() {});
    });
  }

  contactsInit() async {
    final permission = await FlutterContacts.requestPermission();

    if (permission == false) {
      return;
    }

    var box = _store.box<Contacts>();
    var allBox = box.getAll();

    // box.removeAll();

    if (allBox.isNotEmpty) {
      conts = allBox;
    } else {
      final contacts = await FlutterContacts.getContacts(
        withAccounts: true,
        withGroups: true,
        withPhoto: true,
        withProperties: true,
        withThumbnail: true,
      );

      var order;

      for (var element in contacts) {
        _contact = Contacts(
          contactId: element.id,
          // id: element.id.hashCode,
          displayName: element.displayName,
          first: element.name.first,
          last: element.name.last,
          middle: element.name.middle,
          prefix: element.name.prefix,
          suffix: element.name.suffix,
          lastPhonetic: element.name.lastPhonetic,
          middlePhonetic: element.name.middlePhonetic,
          firstPhonetic: element.name.firstPhonetic,
          nickname: element.name.nickname,
        );
        for (var phoneNum in element.phones) {
          order = Phones(
            normalizedNumber: phoneNum.normalizedNumber,
            number: phoneNum.number,
          );
        }
        order.contact.target = _contact;

        print(_contact);

        var all = box.getAll();

        if (all.isEmpty) {
          box.put(_contact);
        } else {
          for (var contact in all) {
            if (contact.contactId == _contact.contactId) {
            } else {
              box.put(_contact);
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
        builder: (_, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF1d2533),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF2d55e8),
              splashColor: const Color(0xFF2d55e8),
              onPressed: () {},
              child: const Icon(
                Icons.dialpad,
                size: 20,
              ),
            ),
            body: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverPersistentHeader(
                        delegate: CustomSliverAppBar(
                          _store.box<Contacts>().getAll().length,
                          expandedHeight: 350,
                        ),
                        pinned: true,
                      ),
                      () {
                        if (state is DashboardFavorites) {
                          return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Container(
                                  height: 100,
                                  // color: Colors.blue,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/avatar1.jpeg"),
                                    ),
                                  ),
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10.0,
                                      bottom: 10,
                                    ),
                                    child: CustomText(
                                      text: contactList![index].displayName,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                              childCount: contactList?.length ?? 0,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                            ),
                          );
                        }
                        return SliverToBoxAdapter(
                          child: !isInitialized
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : StreamBuilder<List<Contacts>>(
                                  stream: _stream,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: BouncingScrollPhysics(),
                                        itemCount: snapshot.data?.length ?? 0,
                                        primary: false,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final contact = snapshot.data![index];
                                          return Container(
                                            color: Color(0xFF141b26),
                                            height: 100,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                    height: 100,
                                                    width: 100,
                                                    child: () {
                                                      // if (contact.photo == null) {
                                                      //   var firstName =
                                                      //       contact.name.first;
                                                      //   var middleName =
                                                      //       contact.name.middle;
                                                      //   var lastName =
                                                      //       contact.name.last;

                                                      //   if (firstName.isNotEmpty &&
                                                      //       lastName.isNotEmpty) {
                                                      //     return Container(
                                                      //       decoration:
                                                      //           BoxDecoration(
                                                      //         color: Colors
                                                      //             .amberAccent
                                                      //             .withOpacity(0.5),
                                                      //         border: Border(
                                                      //           bottom:
                                                      //               BorderSide(),
                                                      //         ),
                                                      //       ),
                                                      //       alignment: Alignment
                                                      //           .bottomCenter,
                                                      //       child: CustomText(
                                                      //         text:
                                                      //             "${firstName[0].toUpperCase()}${lastName[0].toLowerCase()}",
                                                      //         color: Colors
                                                      //             .amberAccent,
                                                      //         fontSize: 20.0 *
                                                      //             MediaQuery.of(
                                                      //                     context)
                                                      //                 .devicePixelRatio,
                                                      //         fontWeight:
                                                      //             FontWeight.w700,
                                                      //       ),
                                                      //     );
                                                      //   }
                                                      //   if (firstName.isNotEmpty &&
                                                      //       lastName.isEmpty &&
                                                      //       middleName.isNotEmpty) {
                                                      //     return Container(
                                                      //       decoration:
                                                      //           BoxDecoration(
                                                      //         color: Colors
                                                      //             .amberAccent
                                                      //             .withOpacity(0.5),
                                                      //         border: Border(
                                                      //           bottom:
                                                      //               BorderSide(),
                                                      //         ),
                                                      //       ),
                                                      //       alignment: Alignment
                                                      //           .bottomCenter,
                                                      //       child: CustomText(
                                                      //         text:
                                                      //             "${firstName[0].toUpperCase()}${middleName[0].toLowerCase()}",
                                                      //         color: Colors
                                                      //             .amberAccent,
                                                      //         fontSize: 20.0 *
                                                      //             MediaQuery.of(
                                                      //                     context)
                                                      //                 .devicePixelRatio,
                                                      //         fontWeight:
                                                      //             FontWeight.w700,
                                                      //       ),
                                                      //     );
                                                      //   }

                                                      //   if (firstName.isNotEmpty &&
                                                      //       lastName.isEmpty &&
                                                      //       middleName.isEmpty) {
                                                      //     return Container(
                                                      //       decoration:
                                                      //           BoxDecoration(
                                                      //         color: Colors
                                                      //             .amberAccent
                                                      //             .withOpacity(0.5),
                                                      //         border: Border(
                                                      //           bottom:
                                                      //               BorderSide(),
                                                      //         ),
                                                      //       ),
                                                      //       alignment: Alignment
                                                      //           .bottomCenter,
                                                      //       child: CustomText(
                                                      //         text:
                                                      //             "${firstName[0].toUpperCase()}${firstName[1].toLowerCase()}}",
                                                      //         color: Colors
                                                      //             .amberAccent,
                                                      //         fontSize: 20.0 *
                                                      //             MediaQuery.of(
                                                      //                     context)
                                                      //                 .devicePixelRatio,
                                                      //         fontWeight:
                                                      //             FontWeight.w700,
                                                      //       ),
                                                      //     );
                                                      //   }
                                                      // }
                                                      return CustomText(
                                                        text: contact.id
                                                            .toString(),
                                                      );
                                                      // return Image.memory(
                                                      //   contact.photo ?? Uint8List(2),
                                                      // );
                                                    }()),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text:
                                                            contact.displayName,
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      () {
                                                        return SizedBox
                                                            .shrink();
                                                      }(),
                                                      // Flexible(
                                                      //   child: Column(
                                                      //       children: contact.phones
                                                      //           .map(
                                                      //             (e) =>
                                                      CustomText(
                                                        text: contact
                                                            .phone.length
                                                            .toString(),
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      // )
                                                      //           .toList()),
                                                      // ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                        );
                      }(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        listener: (_, state) {});
  }
}

class CustomSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final int contactsLength;

  @override
  const CustomSliverAppBar(
    this.contactsLength, {
    required this.expandedHeight,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 170;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      builder: (_, state) {
        return Stack(
          fit: StackFit.loose,
          children: [
            buildAppBar(
              shrinkOffset,
              contactsLength,
              context,
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          context.read<DashboardCubit>().favoritesPressed();
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 3,
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: () {
                                  if (state is DashboardFavorites) {
                                    return Colors.white;
                                  }
                                  return Colors.white.withOpacity(0.2);
                                }(),
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              Icons.favorite_outline_outlined,
                              color: () {
                                if (state is DashboardFavorites) {
                                  return Colors.white;
                                }
                                return Colors.white.withOpacity(0.2);
                              }(),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          context.read<DashboardCubit>().historyPressed();
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 3,
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: () {
                                  if (state is DashboardHistory) {
                                    return Colors.white;
                                  }
                                  return Colors.white.withOpacity(0.2);
                                }(),
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              Icons.history,
                              color: () {
                                if (state is DashboardHistory) {
                                  return Colors.white;
                                }
                                return Colors.white.withOpacity(0.2);
                              }(),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          context.read<DashboardCubit>().contactsPressed();
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 3,
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: () {
                                  if (state is DashboardContacts) {
                                    return Colors.white;
                                  }
                                  return Colors.white.withOpacity(0.2);
                                }(),
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              Icons.person,
                              color: () {
                                if (state is DashboardContacts) {
                                  return Colors.white;
                                }
                                return Colors.white.withOpacity(0.2);
                              }(),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 10.0,
                    bottom: 60,
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 18),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 18),
                      Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
      listener: (_, state) {},
    );
  }
}

Widget buildAppBar(
  double shrinkOffset,
  int contactsLength,
  BuildContext context,
) {
  final h = shrinkOffset;

  ///Using linear regression to find the relationship between two points
  ///Using the formula y = m * x + b;
  ///where m = slope and  b = coefficient constant
  ///slope = (y2 -y1)/(x2 -x1)
  var slope = (35 - 45) / (num.parse("220") - 45);
  var slopeSubText = (15 - 17) / (num.parse("220") - 17);

  ///Making b the s.o.f.
  ///b = y - (m * x)
  ///find b using data point 1 (50, 50)

  var b = 45 - (slope * 45);
  var c = 17 - (slopeSubText * 17);

  ///After finding it all plug it into the metrics equation.

  // if (h > 50) {
  var fontsize = (slope * h) + b;
  var fontSize2 = (slopeSubText * h) + c;

  return BlocConsumer<DashboardCubit, DashboardState>(
    listener: (context, state) {},
    builder: (context, state) {
      return AppBar(
        backgroundColor: const Color(0xFF1d2533),
        elevation: 0,
        toolbarHeight: 350,
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: () {
                if (state is DashboardFavorites) {
                  return "Favorites";
                }

                if (state is DashboardHistory) {
                  return "History";
                }
                if (state is DashboardContacts) {
                  return "Contacts";
                }
              }(),
              fontSize: fontsize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            CustomText(
              text: "$contactsLength contacts",
              fontSize: fontSize2,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ],
        ),
      );
    },
  );
}
