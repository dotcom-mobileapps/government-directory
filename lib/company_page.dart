import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:government_directory/add_advert.dart';
import 'package:government_directory/favourites.dart';
import 'package:government_directory/search_page.dart';
import 'package:government_directory/view_advert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/company.dart';
import 'package:http/http.dart' as http;

class company_page extends StatefulWidget {
  final Company company;
  final BuildContext old_context;
  company_page({Key key, this.company, this.old_context}) : super(key: key);

  @override
  _company_page_state createState() =>
      _company_page_state(this.company, this.old_context);
}

enum AppBarBehavior { normal, pinned, floating, snapping }
const String _logged_in_key = 'loggedin';
class _company_page_state extends State<company_page>
    with TickerProviderStateMixin {
  final Company company;
  final old_context;

  _company_page_state(this.company, this.old_context);
  AnimationController _containerController;
  Animation<double> width;
  Animation<double> height;
  DecorationImage type;

  bool _has_advert = false;

  double _appBarHeight = 256.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  SharedPreferences _preferences;

  bool _is_in_async_call = false;
  String user_id;

  Future _is_my_favourite() async {
    var data = jsonEncode({'company_id': company.id, 'user_id': user_id});

    print('data is ' + data);

    setState(() {
      _is_in_async_call = true;
    });

    final response = await http
        .post('https://government.co.za/api/is_my_favourite', body: data)
        .then((response) {
      setState(() {
        _is_in_async_call = false;
      });
      var res = json.decode(response.body);

      print('response is ${res}');
      if (res['favourite'] == "yes") {
        setState(() {
          _is_favourite = true;
        });
        print('company is my favourite');
      } else {
        setState(() {
          _is_favourite = false;
        });
        print('company is not my favourite user id is ${user_id}');
      }
    }).catchError((error) {
      print('error is ' + error);
      setState(() {
        _is_in_async_call = false;
      });
    });
  }

  Future _add_company_to_favourite() async{
    var data = json.encode({'company_id':company.id, 'user_id':user_id});

    print('adding company as my favourite ' + data);

    setState((){
      _is_in_async_call = true;
    });

    //sending data to the server

    final response = await http
    .post('https://government.co.za/api/add_favourite/', body: data)
    .then((response){
      setState((){
        _is_in_async_call = false;
      });
      var incoming_data = json.decode(response.body);
      print('response data is ' + incoming_data);
      print('company added to favourites');
    }).catchError((error){
      print('error is ' + error);
      setState((){
        _is_in_async_call = false;
      });
    });
  }

  Future _delete_company_from_favourite_list() async {
    var data = json.encode({'company_id':company.id, 'user_id':user_id});

    setState((){
      _is_in_async_call = true;
    });

    final response = await http
    .post('https://government.co.za/api/delete_favourite/',body: data)
    .then((response){
      setState((){
        _is_in_async_call = false;
      });
      var incoming_data = json.decode(response.body);
      
      print('company removed from favourites');
    }).catchError((error){
      print('error occured' + error.toString());
      setState((){
        _is_in_async_call = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      _preferences = sp;
      setState(() {
        user_id = _preferences.getString('id');

        if(company.advert_link == null || company.advert_link == ""){

        }else{
          _has_advert = true;
        }
      });

      _is_my_favourite();
    });

    _containerController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    super.initState();
    width = new Tween<double>(
      begin: 200.0,
      end: 220.0,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );

    height = new Tween<double>(
      begin: 400.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );

    height.addListener(() {
      setState(() {
        if (height.isCompleted) {}
      });
    });
    _containerController.forward();
  }

  @override
  void dispose() {
    _containerController.dispose();
    super.dispose();
  }

  bool _is_favourite = false;

  void _show_company_connection(BuildContext context, String action) {
    Icon connection_icon;
    String company_connection_data;
    String title;
    bool _empty = false;

    try {
      if (action == 'phone') {
        //show company phone number
        connection_icon = new Icon(Icons.phone, color: Colors.cyan);
        title = 'company phone number';
        if (company.mobile.isEmpty) {
          _empty = true;
        } else {
          _empty = false;
          company_connection_data = '${company.mobile}';
        }
      }
    } catch (ex) {
      _empty = true;
      print('exception caught while checking company phone number');
    }

    try {
      if (action == 'fax') {
        //show company fax number
        connection_icon = new Icon(Icons.print, color: Colors.cyan);
        title = 'company fax number';
        if (company.fax.isEmpty) {
          _empty = true;
        } else {
          _empty = false;
          company_connection_data = '${company.fax}';
        }
      }
    } catch (ex) {
      _empty = true;
      print('exception caught while checking company fax number');
    }

    try {
      if (action == 'email') {
        //show company email
        connection_icon = new Icon(Icons.email, color: Colors.cyan);
        title = 'company email address';
        if (company.email.isEmpty) {
          _empty = true;
        } else {
          _empty = false;
          company_connection_data = '${company.email}';
        }
      }
    } catch (ex) {
      _empty = true;
      print('exception caught while checking company email address');
    }
//catch exceptions in case one filed is null
    try {
      if (action == 'web') {
        //show company website
        connection_icon = new Icon(Icons.web, color: Colors.cyan);
        title = 'company website';
        if (company.website.isEmpty) {
          _empty = true;
        } else {
          _empty = false;
          company_connection_data = '${company.website}';
        }
      }
    } catch (ex) {
      _empty = true;
      //company_connection_data = '';
      print('exception caught while cheking company website');
    }

    try {
      if (action == 'location') {
        //show company location
        connection_icon = new Icon(Icons.location_on, color: Colors.cyan);
        title = 'company location';
        if (company.address.isEmpty) {
          _empty = true;
        } else {
          _empty = false;
          company_connection_data = '${company.address}';
        }
      }
    } catch (ex) {
      _empty = true;
      print('exception caught while trying to read company location');
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: connection_icon,
                title: Text(title),
              ),
              new ListTile(
                leading: new Text(''),
                title: _empty
                    ? Text('This company has no ${title}')
                    : Text('${company_connection_data}'),
              ),
              SizedBox(
                height: 15.0,
              ),
            ],
          );
        });
  }

  void _menu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favourites'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavouritesPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Video Channel'),
                onTap: () {
                  print('video channel tabbed');
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Add A Free Advert',style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontSize: 16.0,
                )),
                onTap: () {
                  print('add free add tabed');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => add_advert()));
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout',style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontSize: 16.0,
                )),
                onTap: () {
                  print('log out tabed');
                  _remove_local_data(_logged_in_key);
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                },
              )
            ],
          );
        });
  }

  void _remove_local_data(String key){
    _preferences?.remove(key);
  }

  String render_company_image() {
    bool _empty = false;
    try {
      if (company.url.isEmpty || company.url == null) {
        _empty = true;
      }
    } catch (ex) {
      _empty = true;
      print(
          'rendering company image caused an exception but it was handled mate');
    }

    if (_empty) {
      return 'http://jlouage.com/images/intro-bg.jpg';
    } else {
      return 'http://cdn.adslive.com/${company.url}';
    }
  }

  _render_icon() {
    _is_favourite ? Icon(Icons.favorite) : Icon(Icons.favorite_border);
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.7;

    // Widget _fab(){
    //   return Scaffold(
    //     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //     floatingActionButton: FloatingActionButton(
    //             onPressed: (){},
    //   tooltip: 'test',
    //   child: Icon(Icons.add),
    //   elevation: 2.0,
    //     ),
    //   );
    // }

    return Scaffold(
      body: //new Theme(
          // data: new ThemeData(
          //   brightness: Brightness.light,
          //   primaryColor: const Color.fromRGBO(106, 94, 175, 1.0),
          //   platform: Theme.of(context).platform,
          // ),
          Container(
        //width: width.value,
        //height: height.value,
        color: Colors.white, //const Color.fromRGBO(106, 94, 175, 1.0),
        child: new Hero(
          tag: "img",
          child: new Card(
            color: Colors.transparent,
            child: new Container(
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
              ),
              child: new Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  new CustomScrollView(
                    shrinkWrap: false,
                    slivers: <Widget>[
                      new SliverAppBar(
                        iconTheme: IconThemeData(
                          color: Colors.black,
                        ),
                        elevation: 0.0,
                        forceElevated: true,
                        expandedHeight: _appBarHeight,
                        pinned: _appBarBehavior == AppBarBehavior.pinned,
                        floating: _appBarBehavior == AppBarBehavior.floating ||
                            _appBarBehavior == AppBarBehavior.snapping,
                        flexibleSpace: new FlexibleSpaceBar(
                          title: new Container(),
                          background: new Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              new Container(
                                //width: width.value,
                                height: _appBarHeight,
                                decoration: new BoxDecoration(
                                  color: Colors.green,
                                  image: new DecorationImage(
                                    image: new NetworkImage(
                                        //company.url.isEmpty ? 'http://jlouage.com/images/intro-bg.jpg' : 'http://cdn.adslive.com/${company.url}'),
                                        render_company_image()),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      new SliverList(
                        delegate: new SliverChildListDelegate(<Widget>[
                          new Container(
                            color: Colors.white,
                            child: new Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: MediaQuery.of(context).size.width - 100,
                                        child: Text(company.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                              fontSize: 20.0,
                                            )),
                                      ),
                                      Spacer(),
                                      Container(
                                        child: _is_in_async_call ? CircularProgressIndicator() : GestureDetector(
                                          child: _is_favourite ? Icon(Icons.favorite,size: 35.0,color: Colors.grey,) : Icon(Icons.favorite_border,size: 35.0,color: Colors.grey,),
                                          onTap: (){
                                            if(_is_favourite){
                                              setState((){
                                                _is_favourite = false;
                                              });
                                              _delete_company_from_favourite_list();
                                            }else{
                                              setState((){
                                                _is_favourite = true;
                                              });
                                              _add_company_to_favourite();
                                            }
                                          },
                                        ),
                                      ),
                                      // GestureDetector(
                                      //   child: Icon(
                                      //     Icons.star_border,
                                      //     size: 35.0,
                                      //     color: Colors.grey,
                                      //   ),
                                      //   onTap: () {},
                                      // ),
                                    ],
                                  ),
                                  // Text(company.name, style: TextStyle(
                                  //   fontWeight: FontWeight.bold,
                                  //   fontSize: 20,
                                  // )),
                                  new Container(
                                    padding: new EdgeInsets.only(bottom: 20.0),
                                    alignment: Alignment.center,
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        border: new Border(
                                            bottom: new BorderSide(
                                                color: Colors.black12))),
                                    child: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                IconButton(
                                                  icon: new Icon(
                                                    Icons.phone,
                                                    color: Colors.cyan,
                                                  ),
                                                  onPressed: () {
                                                    //print('company image ${company.url}');
                                                    _show_company_connection(
                                                        context, 'phone');
                                                  },
                                                ),
                                                new Text("Telephone"),
                                                // new Padding(
                                                //   padding:
                                                //       const EdgeInsets.all(4.0),
                                                //   child: new Text("Telephone"),
                                                // )
                                              ],
                                            ),
                                          ],
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                IconButton(
                                                  icon: new Icon(
                                                    Icons.print,
                                                    color: Colors.cyan,
                                                  ),
                                                  onPressed: () {
                                                    _show_company_connection(
                                                        context, 'fax');
                                                  },
                                                ),
                                                Text('Fax'),
                                              ],
                                            ),
                                          ],
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                            IconButton(
                                              icon: new Icon(
                                                Icons.email,
                                                color: Colors.cyan,
                                              ),
                                              onPressed: () {
                                                _show_company_connection(
                                                    context, 'email');
                                              },
                                            ),
                                            Text('Email'),
                                              ],
                                            )

                                          ],
                                        ),
                                        //old version
                                        // new Row(
                                        //   children: <Widget>[
                                        //     IconButton(
                                        //       icon: new Icon(
                                        //         Icons.language,
                                        //         color: Colors.cyan,
                                        //       ),
                                        //       onPressed: () {
                                        //         _show_company_connection(
                                        //             context, 'web');
                                        //       },
                                        //     ),
                                        //   ],
                                        // ),
                                        new Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                            IconButton(
                                              icon: new Icon(
                                                Icons.language,
                                                color: Colors.cyan,
                                              ),
                                              onPressed: () {
                                                _show_company_connection(
                                                    context, 'web');
                                              },
                                            ),
                                            Text('Web')
                                              ],
                                            )

                                          ],
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                            IconButton(
                                              icon: new Icon(
                                                Icons.location_on,
                                                color: Colors.cyan,
                                              ),
                                              onPressed: () {
                                                _show_company_connection(
                                                    context, 'location');
                                              },
                                            ),
                                                Text('Location')
                                              ],
                                            )

                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  new Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16.0, bottom: 8.0),
                                    child: new Text(
                                      'ABOUT',
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  company.about_us.isEmpty
                                      ? Text('Company information not found')
                                      : Text('${company.about_us}'),
                                  //new Text('${company.about_us}'),
                                ],
                              ),
                            ),
                          )
                        ]),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:  FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _has_advert ? FloatingActionButton.extended(
        elevation: 4.0,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.view_carousel),
        label: const Text('view ad'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => view_advert_page(company.advert_link,company.name)));
        },
      ) : null,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _menu(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                print('search pressed');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => search_page()));
              },
            )
          ],
        ),
      ),
    );

    // return new Theme(

    //   data: new ThemeData(
    //     brightness: Brightness.light,
    //     primaryColor: const Color.fromRGBO(106, 94, 175, 1.0),
    //     platform: Theme.of(context).platform,
    //   ),
    //   child: new Container(
    //     width: width.value,
    //     height: height.value,
    //     color: const Color.fromRGBO(106, 94, 175, 1.0),
    //     child: new Hero(
    //       tag: "img",
    //       child: new Card(
    //         color: Colors.transparent,
    //         child: new Container(
    //           alignment: Alignment.center,
    //           width: width.value,
    //           height: height.value,
    //           decoration: new BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: new BorderRadius.circular(10.0),
    //           ),
    //           child: new Stack(
    //             alignment: AlignmentDirectional.bottomCenter,
    //             children: <Widget>[
    //               new CustomScrollView(
    //                 shrinkWrap: false,
    //                 slivers: <Widget>[
    //                   new SliverAppBar(
    //                     elevation: 0.0,
    //                     forceElevated: true,
    //                     // leading: new IconButton(
    //                     //   onPressed: (){
    //                     //     Navigator.of(context).pop();
    //                     //   },
    //                     //   icon: new Icon(Icons.arrow_back, color: Colors.cyan,size: 30.0,),
    //                     // ),
    //                     expandedHeight: _appBarHeight,
    //                     pinned: _appBarBehavior == AppBarBehavior.pinned,
    //                     floating: _appBarBehavior == AppBarBehavior.floating || _appBarBehavior == AppBarBehavior.snapping,
    //                     flexibleSpace: new FlexibleSpaceBar(
    //                       title: //new Text('${company.name}'),
    //                       new Container(
    //                         width: width.value,
    //                         child: Text('${company.name}'),
    //                       ),
    //                       background: new Stack(
    //                         fit: StackFit.expand,
    //                         children: <Widget>[
    //                           new Container(
    //                             width: width.value,
    //                             height: _appBarHeight,
    //                             decoration: new BoxDecoration(
    //                             //image: ,

    //                             ),
    //                           )
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   new SliverList(
    //                     delegate: new SliverChildListDelegate(<Widget>[
    //                       new Container(
    //                         color: Colors.white,
    //                         child: new Padding(
    //                           padding: const EdgeInsets.all(35.0),
    //                           child: new Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //                               new Container(
    //                                 padding: new EdgeInsets.only(bottom: 20.0),
    //                                 alignment: Alignment.center,
    //                                 decoration: new BoxDecoration(
    //                                   color: Colors.white,
    //                                   border: new Border(
    //                                     bottom: new BorderSide(
    //                                       color: Colors.black12
    //                                     )
    //                                   )
    //                                 ),
    //                                 child: new Row(
    //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                   children: <Widget>[
    //                                     new Row(
    //                                       children: <Widget>[new Icon(Icons.access_time, color: Colors.cyan,),
    //                                       new Padding(
    //                                         padding: const EdgeInsets.all(8.0),
    //                                         child: new Text("10:00 am"),
    //                                       )
    //                                       ],
    //                                     ),
    //                                     new Row(
    //                                       children: <Widget>[
    //                                         new Icon(Icons.map,
    //                                         color: Colors.cyan,
    //                                         ),
    //                                         new Padding(
    //                                           padding: const EdgeInsets.all(8.0),
    //                                           child: new Text('15 miles'),
    //                                         )
    //                                       ],
    //                                     )
    //                                   ],
    //                                 ),
    //                               ),
    //                               new Padding(
    //                                 padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
    //                                 child: new Text('ABOUT', style: new TextStyle(fontWeight: FontWeight.bold),
    //                                 ),
    //                               ),
    //                               new Text(
    //                                 '${company.about_us}'
    //                               ),

    //                             ],
    //                           ),
    //                         ),
    //                       )
    //                     ]),
    //                   )
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class _drawer extends StatelessWidget {
  const _drawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          _custom_list_tile(),
        ],
      ),
    );
  }

  Widget _custom_list_tile() {
    return ListTile(
      leading: Icon(Icons.face),
      title: Text('test'),
    );
  }
}
