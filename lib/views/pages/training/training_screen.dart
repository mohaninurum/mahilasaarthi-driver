import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mahilasaarthi/models/traningModel.dart';
import 'package:mahilasaarthi/widgets/imagePreview.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../constants/api.dart';
import '../../../services/toast.service.dart';
import '../../../utils/utils.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
class Training_Screen extends StatefulWidget {
  const Training_Screen({super.key});

  @override
  State<Training_Screen> createState() => _Training_ScreenState();
}

class _Training_ScreenState extends State<Training_Screen> {
  bool isloading = true;
  TrainingModelResponse trainingModelResponse = TrainingModelResponse();


  Future<void> callApi() async {
    final response = await get(Uri.parse(Api.baseUrl + "/driverTrainingContent"));
    isloading = false;
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      trainingModelResponse = TrainingModelResponse.fromJson(data);
    }
    setState(() {});
  }

@override
  void initState() {
    callApi();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:context.primaryColor,
        leading: IconButton(
          icon: Icon(
            !Utils.isArabic
                ? FlutterIcons.arrow_left_fea
                : FlutterIcons.arrow_right_fea,
          ),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          "Driver Training",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(padding: EdgeInsets.symmetric(horizontal: 5,vertical: 15),child:isloading == true ? Center(child: CircularProgressIndicator()):
      ListView.builder(
          itemCount: trainingModelResponse.data!.length ,
          itemBuilder: (context, index) {
            TrainingModel product = trainingModelResponse.data![index];
       return product.fileType == "image" || product.fileType == "video" || product.fileType == "audio" ? VideoWidget(product): DocWidget(product);
          })),
    );
  }
  Widget VideoWidget (TrainingModel product){
    return GestureDetector(
      onTap: () async {
        // launchUrl(url,mode: LaunchMode.externalApplication)
        //   launchUrl(Uri.parse(Api.driver_traininUri +product.fileName.toString()),mode: LaunchMode.inAppWebView);

        if(product.fileType == "image"){
         Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreview(uri: Api.driver_traininUri +product.fileName.toString()),));
        }else{
        if(product.fileType == "video"){
          launchUrl(Uri.parse(Api.driver_traininUri +product.fileName.toString()));
        }else{

          Utils.showLoadingDialog(context);
          final url = Uri.parse(Api.driver_traininUri +product.fileName.toString());
          final response = await get(url);
          final directory = await getExternalStorageDirectory();
          final path = directory!.path;
          log("path : " + path.toString());
          final file = File('$path/' + product.fileName.toString());
          file.writeAsBytes(response.bodyBytes);
          // GallerySaver.saveImage(file.path);
          Navigator.pop(context);
          ToastService.toastSuccessful("File download successfully");
          OpenFile.open('$path/' + product.fileName.toString());
        }

        }
      },
      child: Container( margin: const EdgeInsets.only(right: 5,left: 5,bottom: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Text(product.title.toString(),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
        SizedBox(height: 8,),
          Text(product.description .toString(),style: TextStyle(color: Colors.black,fontSize: 14),),
          SizedBox(height: 10,),
          SizedBox(height: 160,width: double.infinity,child: Image.network(product.photo.toString(),fit: BoxFit.fill,)),
          SizedBox(height: 10,),
          Divider(color: Colors.grey,)
        ],),),
    );
  }
  Widget DocWidget (TrainingModel product){
    return GestureDetector(
      onTap: () async {
        // launchUrl(url,mode: LaunchMode.externalApplication)
        //   launchUrl(Uri.parse(Api.driver_traininUri +product.fileName.toString()),mode: LaunchMode.inAppWebView);
        // if(product.fileName.toString().contains(".doc") || product.fileName.toString().contains(".pptx")){
        //   launchUrl(Uri.parse(Api.driver_traininUri +product.fileName.toString()),mode: LaunchMode.externalApplication);
        // }else{
          Utils.showLoadingDialog(context);
          final url = Uri.parse(Api.driver_traininUri +product.fileName.toString());
          final response = await get(url);
          final directory = await getExternalStorageDirectory();
          final path = directory!.path;
          log("path : " + path.toString());
          final file = File('$path/' + product.fileName.toString());
          file.writeAsBytes(response.bodyBytes);
          // GallerySaver.saveImage(file.path);
          Navigator.pop(context);
          ToastService.toastSuccessful("File download successfully");
          OpenFile.open('$path/' + product.fileName.toString());

        // }

      },
      child: Container(  margin: const EdgeInsets.only(right: 5,left: 5,bottom: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),child: Column(
          children: [
            Row(children: [
              SizedBox(height: 80,width: 110,child: Image.network(product.photo.toString(),fit: BoxFit.fill,)),
             SizedBox(width: 15,),
               Expanded(
                 child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,children: [
                   Text(product.title.toString(),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),overflow: TextOverflow.ellipsis),
                   SizedBox(height: 4,),
                   Text(product.description .toString(),style: TextStyle(color: Colors.black,fontSize: 14),overflow: TextOverflow.ellipsis,),
                 ],),
               )
                   ],),
                  SizedBox(height: 10,),
          Divider(color: Colors.grey,)
          ],
        ),),
    );
  }
}
