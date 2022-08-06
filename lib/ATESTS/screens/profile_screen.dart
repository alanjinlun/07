import 'dart:async';
import 'dart:typed_data';
import 'package:aft/ATESTS/screens/profile_screen_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/streams.dart';
// import 'package:provider/provider.dart';
import '../feeds/message_card.dart';
import '../feeds/poll_card.dart';
import '../models/poll.dart';
import '../models/post.dart';
import '../models/postPoll.dart';
import '../models/user.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';
import '../methods/auth_methods.dart';

class Profile extends StatefulWidget {
  final Post post;
  const Profile({Key? key, required this.post}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final _key1 = GlobalKey();
  final AuthMethods _authMethods = AuthMethods();
  late Post _post;
  bool posts = true;
  bool comment = false;
  Uint8List? _image;
  int commentLen = 0;
  int _selectedIndex = 0;
  bool selectFlag = false;
  User? _userProfile;
  final ScrollController _scrollController = ScrollController();
  TabController? _tabController;

  List<dynamic> postList = [];
  List<dynamic> pollList = [];
  StreamSubscription? loadDataStream;

  initList(index) async {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
      pollList = [];
      postList = [];
    }
    if (index == 0) {
      loadDataStream = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: _post.uid)
        .orderBy('score', descending: true)
        .snapshots().listen((event) {
          print("aaaaaaaaaaaaaaaaaaaaaaaa");
          if (postList.isEmpty) {
            event.docChanges.forEach((change) {
              postList.add(change.doc.data()!);
            });
          } else {
            for (var change in event.docChanges) {
              switch (change.type) {
                case DocumentChangeType.added:
                  postList.add({
                    ...change.doc.data()!,
                  }); 
                  break; 
                case DocumentChangeType.modified:
                  int i = postList.indexWhere((element) => element["postId"] == change.doc.data()!["postId"]);
                  postList[i] = change.doc.data();
                  break;
                case DocumentChangeType.removed:
                  postList.remove({
                    ...change.doc.data()!
                  }); 
                  break;
              }
            }
          }
          setState(() {
          });
        });
    } else if (index == 1) {
      loadDataStream = FirebaseFirestore.instance
        .collection('polls')
        .where('uid', isEqualTo: _post.uid)
        .orderBy('totalVotes', descending: true)
        .snapshots().listen((event) {
          print(event.docs.length);
          print("bbbbbbbbbbbbbbbbbbbbbbbbb");
          if (pollList.isEmpty) {
            event.docChanges.forEach((change) {
              pollList.add(change.doc.data()!);
            });
            setState(() {});
          } else {
            for (var change in event.docChanges) {
              switch (change.type) {
                case DocumentChangeType.added:
                  pollList.add({
                    ...change.doc.data()!,
                  }); 
                  break; 
                case DocumentChangeType.modified:
                  int i = pollList.indexWhere((element) => element["pollId"] == change.doc.data()!["pollId"]);
                  pollList[i] = change.doc.data();
                  break;
                case DocumentChangeType.removed:
                  pollList.remove({
                    ...change.doc.data()!
                  }); 
                  break;
              }
            }
            setState(() {});
          }
          setState(() {});
        });
    }
  }
  
  // void getComments() async {
  //   try {
  //     QuerySnapshot snap = await FirebaseFirestore.instance
  //         .collection('posts')

  //         // .where('uid', isEqualTo: _post.uid)
  //         .get();

  //     setState(() {
  //       commentLen = snap.docs.length;
  //     });
  //   } catch (e) {
  //     showSnackBar(e.toString(), context);
  //   }
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    initTabController();
    getUserDetails();
    initList(0);
    // loadCountryFlagValue();
  }

  initTabController() {
    if (_tabController != null) {
      _tabController!.dispose();
    }

    _tabController = TabController(length: 3, vsync: this);
    
    _tabController?.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        initList(_selectedIndex);
      });
    });
  }

  getUserDetails() async {
    User userProfile = await _authMethods.getUserProfileDetails(_post.uid);
    setState(() {
      _userProfile = userProfile;
    });
  }

  // void selectImage() async {
  //   Uint8List im = await pickImage(ImageSource.gallery);
  //   setState(() {
  //     _image = im;
  //   });
  // }
  TabBar get _tabBar => TabBar(
        tabs: [
          Tab(icon: Icon(Icons.call)),
          Tab(icon: Icon(Icons.message)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    return DefaultTabController(
      length: 3,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            // backgroundColor: Color.fromARGB(255, 245, 245, 245),
            backgroundColor: Color.fromARGB(255, 245, 245, 245),
            body: NestedScrollView(
              controller: _scrollController,
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                Container(
                  // decoration: BoxDecoration(
                  //     border: Border(
                  //         bottom: BorderSide(
                  //   color: Colors.grey,
                  // ))),
                  child: SliverAppBar(
                    shape: Border(
                        bottom: BorderSide(
                            color: Color.fromARGB(255, 201, 201, 201))),
                    pinned: true,
                    floating: true,
                    snap: true,
                    bottom: TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(
                            Icons.message_outlined,
                          ),
                          text: 'Messages',
                        ),
                        Tab(icon: Icon(Icons.poll_outlined), text: 'Polls'),
                        Tab(
                            icon: Icon(
                              Icons.check_box_outlined,
                            ),
                            text: 'Votes'),
                      ],
                      indicatorColor: Colors.black,
                      indicatorWeight: 5,
                      labelColor: Colors.black,
                      // onTap: (index) {
                      //   _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                      //   initList(index);
                      // },
                      controller: _tabController,
                    ),

                    // floating: true,
                    // backgroundColor: Color.fromARGB(255, 245, 245, 245),
                    backgroundColor: Colors.white,
                    toolbarHeight: 300,
                    automaticallyImplyLeading: false,
                    elevation: 0,

                    actions: [
                      SafeArea(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                                icon: Icon(Icons.arrow_back,
                                                    color: Colors.black),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                }),
                                            Container(width: 8),
                                            Text(
                                              _post.username,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // DropCapText(
                                //   '${user?.bio}',
                                //   textAlign: TextAlign.start,
                                //   style: TextStyle(color: Colors.black, fontSize: 11),
                                //   dropCapPosition: DropCapPosition.start,
                                //   mode: DropCapMode.aside,
                                //   dropCap: DropCap(
                                //     width: 90,
                                //     height: 70,
                                //     child: Padding(
                                //       padding: const EdgeInsets.all(8.0),
                                //       child: CircleAvatar(
                                //         radius: 39,
                                //         backgroundColor:
                                //             Color.fromARGB(255, 245, 245, 245),
                                //         child: CircleAvatar(
                                //           radius: 35,
                                //           backgroundImage: NetworkImage(
                                //               'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max'),
                                //           backgroundColor:
                                //               Color.fromARGB(255, 245, 245, 245),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Container(
                                  // color: Colors.green,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 00.0, left: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          // color: Colors.orange,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              140 -
                                              26,
                                          // width: _key1.currentContext?.size!.width,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Container(
                                              //     width:
                                              //         _post.uid == user?.uid ? 8 : 0),
                                              _post.uid == user?.uid
                                                  ? Container(
                                                      key: _key1,
                                                      width: 180,
                                                      // width: MediaQuery.of(context)
                                                      //         .size
                                                      //         .width -
                                                      //     130 -
                                                      //     26,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 0.0,
                                                                left: 0,
                                                                bottom: 10),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const EditProfile()),
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 32,
                                                            width: 110,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      250,
                                                                      250,
                                                                      250),
                                                              border: Border.all(
                                                                  width: 0,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          93,
                                                                          93,
                                                                          93)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .create_outlined,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 17,
                                                                ),
                                                                Container(
                                                                    width: 6),
                                                                Text(
                                                                  'Edit Profile',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Row(),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .perm_contact_calendar_outlined,
                                                    color: Colors.black,
                                                    size: 16,
                                                  ),
                                                  Container(width: 8),
                                                  Text('Joined: ',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      )),
                                                  Text(
                                                      DateFormat.yMMMd().format(
                                                        user?.dateCreated
                                                            .toDate(),
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      )),
                                                ],
                                              ),
                                              Container(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.message_outlined,
                                                    color: Colors.black,
                                                    size: 16,
                                                  ),
                                                  Container(width: 8),
                                                  Container(
                                                    child: StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection('posts')
                                                          .where('uid',
                                                              isEqualTo:
                                                                  _post.uid)
                                                          .snapshots(),
                                                      builder:
                                                          (content, snapshot) {
                                                        return Row(
                                                          children: [
                                                            Text(
                                                              '${(snapshot.data as dynamic)?.docs.length ?? 0} ',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            Text(
                                                              (snapshot.data as dynamic)
                                                                          ?.docs
                                                                          .length ==
                                                                      1
                                                                  ? 'Message'
                                                                  : 'Messages',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.poll_outlined,
                                                    color: Colors.black,
                                                    size: 16,
                                                  ),
                                                  Container(width: 8),
                                                  Container(
                                                    child: StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection('polls')
                                                          .where('uid',
                                                              isEqualTo:
                                                                  _post.uid)
                                                          .snapshots(),
                                                      builder:
                                                          (content, snapshot) {
                                                        return Row(
                                                          children: [
                                                            Text(
                                                              '${(snapshot.data as dynamic)?.docs.length ?? 0} ',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            Text(
                                                              (snapshot.data as dynamic)
                                                                          ?.docs
                                                                          .length ==
                                                                      1
                                                                  ? 'Poll'
                                                                  : 'Polls',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_box_outlined,
                                                    color: Colors.black,
                                                    size: 16,
                                                  ),
                                                  Container(width: 8),
                                                  Container(
                                                    child: StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection('posts')
                                                          .where('plus',
                                                              arrayContains:
                                                                  _post.uid)
                                                          .snapshots(),
                                                      builder:
                                                          (content, snapshot1) {
                                                        return StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'posts')
                                                              .where('minus',
                                                                  arrayContains:
                                                                      _post.uid)
                                                              .snapshots(),
                                                          builder: (content,
                                                              snapshot2) {
                                                            return StreamBuilder(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'posts')
                                                                  .where(
                                                                      'neutral',
                                                                      arrayContains:
                                                                          _post
                                                                              .uid)
                                                                  .snapshots(),
                                                              builder: (content,
                                                                  snapshot3) {
                                                                return StreamBuilder(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'polls')
                                                                      .where(
                                                                          'allVotesUIDs',
                                                                          arrayContains:
                                                                              _post.uid)
                                                                      .snapshots(),
                                                                  builder: (content,
                                                                      snapshot4) {
                                                                    return Row(
                                                                      children: [
                                                                        Text(
                                                                          '${((snapshot1.data as dynamic)?.docs.length ?? 0) + ((snapshot2.data as dynamic)?.docs.length ?? 0) + ((snapshot3.data as dynamic)?.docs.length ?? 0) + ((snapshot4.data as dynamic)?.docs.length ?? 0)} ',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          // ignore: unrelated_type_equality_checks
                                                                          {
                                                                                    ((snapshot1.data as dynamic)?.docs.length ?? 0) + ((snapshot2.data as dynamic)?.docs.length ?? 0)
                                                                                  } ==
                                                                                  1
                                                                              ? 'Vote'
                                                                              : 'Votes',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // color: Colors.orange,
                                        ),
                                        _image != null
                                            ? CircleAvatar(
                                                radius: 35,
                                                backgroundImage:
                                                    MemoryImage(_image!),
                                                backgroundColor: Color.fromARGB(
                                                    255, 245, 245, 245),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0.0, right: 10),
                                                child: Container(
                                                  // color: Colors.red,
                                                  // padding:
                                                  //     EdgeInsets.only(right: 10),
                                                  // color: Colors.blue,
                                                  // alignment:
                                                  //     Alignment.centerRight,

                                                  width: 110,
                                                  child: Stack(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 55,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max'),
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                245, 245, 245),
                                                      ),
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 14,
                                                        child: Container(
                                                          child: Row(
                                                                  children: [
                                                                    _userProfile != null && _userProfile?.profileFlag == "true"
                                                                        ? Container(
                                                                            width:
                                                                                33,
                                                                            height:
                                                                                18,
                                                                            child:
                                                                                Image.asset('icons/flags/png/${user?.country}.png', package: 'country_icons'))
                                                                        : Row()
                                                                  ])
                                                        ),
                                                      ),
                                                      // Positioned(
                                                      //   bottom: 0,
                                                      //   left: 63,
                                                      //   child: Container(
                                                      //       width: 32,
                                                      //       height: 18,
                                                      //       child: selectFlag
                                                      //           ? Image.asset(
                                                      //               'icons/flags/png/${user?.country}.png',
                                                      //               package:
                                                      //                   'country_icons')
                                                      //           : Row()),
                                                      // )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 14.0,
                                          right: 10,
                                          left: 30,
                                          bottom: 4),
                                      child: Container(
                                        // color: Colors.blue,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Text(
                                            _post.uid == user?.uid
                                                ? 'About me'
                                                : 'About ${_post.username}',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ),
                                    ),

                                    //bio si displaying on all profiles
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: 93,
                                          padding: EdgeInsets.only(
                                              bottom: 5,
                                              right: 15,
                                              left: 15,
                                              top: 5),

                                          // width: MediaQuery.of(context).size.width,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 250, 250, 250),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                width: 0, color: Colors.grey),
                                          ),
                                          child: Scrollbar(
                                            child: SingleChildScrollView(
                                              child: Flexible(
                                                child: Text(
                                                  trimText(text: (_userProfile != null ? _userProfile?.bio as String : "")) ==
                                                          ''
                                                      ? 'Empty Bio'
                                                      : trimText(
                                                          text: _userProfile?.bio as String),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: trimText(
                                                                  text:
                                                                      '(_userProfile != null ? _userProfile?.bio as String : "")') ==
                                                              ''
                                                          ? Color.fromARGB(255,
                                                              126, 126, 126)
                                                          : Colors.black,
                                                      fontSize: trimText(
                                                                  text:
                                                                      '(_userProfile != null ? _userProfile?.bio as String : "")') ==
                                                              ''
                                                          ? 12
                                                          : 13,
                                                      fontStyle: trimText(
                                                                  text:
                                                                      '(_userProfile != null ? _userProfile?.bio as String : "")') ==
                                                              ''
                                                          ? FontStyle.italic
                                                          : FontStyle.normal),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                //  Positioned(
                                //         bottom: 0,
                                //         child: Row(
                                //           children: [
                                //             Container(
                                //                 width:
                                //                     MediaQuery.of(context).size.width /
                                //                             2 -
                                //                         83),

                                //             Container(
                                //                 width:
                                //                     MediaQuery.of(context).size.width /
                                //                             2 -
                                //                         83),
                                //           ],
                                //         ),
                                //       ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // body: Text('1'),
              body: TabBarView(
                controller: _tabController,
                children: [
                  postList.isNotEmpty ? 
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: postList.length,
                      itemBuilder: (context, index) {
                        Post post = Post.fromMap(postList[index]);
                        return PostCardTest(
                          post: post,
                          indexPlacement: index,
                        );
                      },
                    )
                  : Container(),
                  pollList.isNotEmpty ? 
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: pollList.length,
                      itemBuilder: (context, index) {
                        Poll poll = Poll.fromMap(pollList[index]);
                        return PollCard(
                          poll: poll,
                          indexPlacement: index,
                        );
                      },
                    )
                  : Container(),
                  Builder(
                    builder: (context) {
                      return StreamBuilder(
                        stream: CombineLatestStream.list([
                          FirebaseFirestore.instance
                            .collection('posts')
                            // .doc()
                            // .collection('comments')
                            .where('allVotesUIDs', arrayContains: _post.uid)
                            .snapshots(),
                          FirebaseFirestore.instance
                              .collection('polls')
                              // .doc()
                              // .collection('comments')
                              .where('allVotesUIDs', arrayContains: _post.uid)
                              .snapshots(),
                        ]),
                        builder: (context,
                            AsyncSnapshot<List<QuerySnapshot<Map<String, dynamic>>>>
                                snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final data0 = snapshot.data![0];
                          final data1 = snapshot.data![1];

                          List<PostPoll> postPoll = [];
                          postPoll.clear();
                          data0.docs.forEach((element) {
                            Post post = Post.fromSnap(element);
                            postPoll.add(PostPoll(
                              datePublished: post.datePublished.toDate(), 
                              category: "post", 
                              item: element));
                          });

                          data1.docs.forEach((element) {
                            Poll poll = Poll.fromSnap(element);
                            postPoll.add(PostPoll(
                              datePublished: poll.datePublished.toDate(), 
                              category: "poll", 
                              item: element));
                          });

                          postPoll.sort((a,b) {
                            return b.datePublished.compareTo(a.datePublished);
                          });

                          postPoll.forEach((e) {
                            print(e.datePublished.toString());
                          });

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: postPoll.length,
                            itemBuilder: (context, index) {
                              if (postPoll[index].category == "post") {
                                Post post = Post.fromSnap(postPoll[index].item);
                                return PostCardTest(
                                  post: post,
                                  indexPlacement: index,
                                );
                              } else {
                                Poll poll = Poll.fromSnap(postPoll[index].item);
                                return PollCard(
                                  poll: poll,
                                  indexPlacement: index,
                                );
                              }
                            },
                          );
                        },
                      );
                    }
                  ),

                  // Text('list of all voted polls + messages'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
