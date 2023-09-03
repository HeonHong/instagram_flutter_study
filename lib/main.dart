import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';//스크롤 닿았을 때 데이터 불러오는 패키지
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';


void main() {

  runApp(
      MaterialApp(
        theme:style.theme,
        initialRoute: '/',
        // routes: {
        //   '/': (context)=>MyApp(),
        //   '/upload': (context)=>Upload(),
        // },
        home: MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var tab = 0;
  var count = 1;
  var flag=0;
  var imageCollection = [Image.asset('DSCF1666.JPG'), Image.asset('DSCF1586.JPG'),  Image.asset('DSCF1653.JPG')];
  var userImage;
  var userContent;

  // saveData() async{
  //   //이런 식으로 해서 instagram데이터 저장해뒀다가 서버가 아니라 저장된 데이터 먼저 보여주면 됨.
  //   //서버 부하 줄이기 good
  //   //이미지는 캐싱해야함.
  //    var storage = await SharedPreferences.getInstance();
  //    storage.setString('name', 'john');
  //    storage.remove('name');
  //
  //    var result = storage.getString('name');
  //    print(result);
  //
  //    var map1 = {'age':20};
  //    storage.setString('map1', jsonEncode(map1));//storage에는 map을 저장할 수 없다. 저장하고 싶으면 json형식으로 저장.
  //    storage.remove('map1');
  //    var result1 = storage.getString('map1')??'없음';
  //     print(result1);
  //
  // }



  List contentData=[];
  var downloadImage=[];

 getData() async {
  print('불렸냐?');
   var storage = await SharedPreferences.getInstance();
   if(  storage.get('contentData') == null){
     print('여기 들리냐?');
     var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
     if(result.statusCode==200){
       setState(() {
         contentData = jsonDecode(result.body);
         storage.setString('contentData', result.body);

         // for(var i=0;i<contentData.length;i++){
         //   downloadImage.add(contentData[i]['image']);
         // }
         print(contentData[0]['image']);
       });
     }
   }else{
      setState(() {
        print('여기서 가져감');
        contentData=jsonDecode(storage.getString('contentData')??'');
        storage.remove('contentData');
      });
   }



   // print(jsonDecode(result.body));
   // print(contentData[1]['likes']);
   // print(contentData);

 }

  getMore() async {
    flag=1;
    print(flag);
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more${count}.json'));
    if(result.statusCode==200){
      setState(() {
        print(result.body);
        contentData.add(jsonDecode(result.body));
        count++;
      });
    }
    flag = 0;
    print(flag);
 }

 addPost(newPost){
   print( newPost['image'].runtimeType);

   setState(() {
     contentData.add(newPost);
   });

   //print(Image.file(newPost['image']));
 }

  setUserContent(text){
   setState(() {
      userContent=text;
   });
  }


  addMyData(){
    var myData={
      "id": contentData.length,
      'image':userImage,
      'likes':0,
      'date':'23/08/30',
      'content':userContent,
      'liked':false,
      'user':3,
    };
    setState(() {
      // contentData.add(myData);
      contentData.insert(0,myData);

    });
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    // saveData();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
             appBar: AppBar(
               title:Text('Instagram'),
               actions: [
                 IconButton(
                     onPressed: () async{
                       var picker = ImagePicker();
                       var image = await picker.pickImage(source: ImageSource.gallery);
                       // var image = await picker.pickMultiImage();
                       if(image!=null){
                         setState(() {
                           userImage = File(image.path);
                         });
                      }


                       Navigator.push(context,
                        MaterialPageRoute(builder: (context){
                          // return Upload(userImage:userImage, addPost:addPost,);
                          return Upload(userImage:userImage, setUserContent:setUserContent,  addMyData: addMyData);
                        })
                       );
                     },
                     icon: Icon(Icons.add_box_outlined)
                 )
               ],),
              body:content(imageColl : imageCollection, contentData:contentData, getMore:getMore, flag:flag, ),
              bottomNavigationBar: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: (i){
                  setState(() {
                    tab=i;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon :  Icon(Icons.home_outlined),
                    label: '홈',
                    ),
                  BottomNavigationBarItem(
                      icon :  Icon(Icons.shopping_bag_outlined),
                      label: '샵'
                  ),
                ],
              ),

    );
  }
}

class content extends StatefulWidget {
  content({super.key, this.imageColl, this.contentData, this.getMore, this.flag});

  final imageColl;
  final contentData;
  final getMore;
  final flag;

  @override
  State<content> createState() => _contentState();
}

class _contentState extends State<content> {

  var scroll = ScrollController();//스크롤 저장함

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scroll.addListener(() {
      // print(scroll.position.maxScrollExtent);
      if(scroll.position.maxScrollExtent==scroll.position.pixels && widget.flag==0){
          widget.getMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
   if(widget.contentData.isNotEmpty){
     return ListView.builder(
         itemCount:widget.contentData.length,
         controller: scroll,
         itemBuilder: (context, i){
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // widget.contentData[i]['image'].runtimeType==String?
               // Image.network(widget.contentData[i]['image']):Image.file(widget.contentData[i]['image']),
               // if(widget.contentData[i]['image'].runtimeType==String) Image.network(widget.contentData[i]['image'])
               // else Image.file(widget.contentData[i]['image']),
               CachedNetworkImage(
                   imageUrl: widget.contentData[i]['image'],
                   // placeholder: (context,url) => CircularProgressIndicator(),
                   errorWidget:(context,url, error) => Icon(Icons.error) ,
               ),
               Text('좋아요 : ${widget.contentData[i]['likes']}'),
               Text('글쓴이 : ${widget.contentData[i]['user']}'),
               Text('글내용 :  ${widget.contentData[i]['content']}'),
             ],
           );
         });
   }else{
     return CircularProgressIndicator();
   }
  }
}

class Upload extends StatelessWidget {
  Upload({super.key, this.userImage, this.setUserContent, this.addMyData});
  final userImage;
  final setUserContent;
  final addMyData;


  @override
  Widget build(BuildContext context) {
    var content='';
    var newPost={
      "id":3,
      'image':userImage,
      'likes':0,
      'date':'23/08/30',
      'content':'',
      'user':3,
    };


    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            addMyData();
            Navigator.pop(context);

          },icon:Icon(Icons.send)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(userImage),
          TextField(onChanged: (text){
            // newPost['content'] = text;
            setUserContent(text);
          },),
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon:Icon(Icons.close)),
          // TextButton(onPressed: (){
          //   addPost(newPost);
          //   Navigator.pop(context);
          // }, child: Text('발행'))
        ],
      ),
    );
  }
}