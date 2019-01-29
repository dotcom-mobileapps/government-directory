import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
class view_advert_page extends StatefulWidget{
final String advert;
final String company_name;
view_advert_page(this.advert,this.company_name);

@override
view_advert_state createState() => view_advert_state(advert: this.advert,company_name: this.company_name);
}

class view_advert_state extends State<view_advert_page>{
  final String advert;
  final String company_name;

  view_advert_state({this.advert,this.company_name});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(company_name),
      ),
      body: PhotoView(
        imageProvider: NetworkImage('https://cdn.adslive.com/${advert}'),
      ),
      // body: Container(
      //   child: FadeInImage.assetNetwork(
      //     placeholder: 'assets/placeholder.png',
      //     height: MediaQuery.of(context).size.height,
      //     width: MediaQuery.of(context).size.width,
      //     fit: BoxFit.fill,
      //     image: 'https://cdn.adslive.com/${advert}',
      //   ),
      // )
    );
  }
}