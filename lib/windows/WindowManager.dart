import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mywebsite/Util/fileManager/files/fileManager.dart';
import 'package:mywebsite/windows/apps/VideoPlayer.dart';
import 'package:mywebsite/windows/apps/fileSystem.dart';
import 'package:mywebsite/windows/apps/pdfReader.dart';
import 'package:mywebsite/windows/draggableWindow.dart';
import 'package:mywebsite/windows/window.dart';

import 'WindowListener.dart';
import 'apps/calculator.dart';
import 'apps/painter.dart';
import 'apps/screenshot.dart';

class WindowManager{

  final VoidCallback onUpdate;

  final assetsAudioPlayer = AssetsAudioPlayer();
  WindowManager({required this.onUpdate}){


    assetsAudioPlayer.open(
      Audio("assets/erro.mp3"),
    );
  }

  List<DraggableWindow> windows = List.empty(growable: true);


  void startCalculatorApp(){

    var key = UniqueKey();
    var appKey = GlobalKey();
    generateSimpleDraggableWindow(CalculatorApp(key: key,appKey: appKey, title: "Calculator"));
  }

  
  
  void startPdfApp(){

    var key = UniqueKey();
    var appKey = GlobalKey();

    generateSimpleDraggableWindow(PdfReaderApp(title: "Pdf Reader",appKey: appKey,key: key,));
  }
  void startPainterApp(){

    var key = UniqueKey();
    var appKey = GlobalKey();

    generateSimpleDraggableWindow(PainterApp(title: "Painter",appKey: appKey, key: key,));

  }

  void startFolderApp(){

    var key = UniqueKey();
    var appKey = GlobalKey();

    generateSimpleDraggableWindow(FolderApp(title: "Folder App",appKey: appKey, key: key,currentFolder: FileManager.getMainFolder(),));

  }
  void startVideoApp(String url){

    var key = UniqueKey();
    var appKey = GlobalKey();

    generateSimpleDraggableWindow(VideoPlayerApp(title: "Folder App",appKey: appKey, key: key,videoUrl: url));

  }



  void generateSimpleDraggableWindow(Application application){


    final draggableWindow =  DraggableWindow(
      key: application.key,
      onCrash: (){
        assetsAudioPlayer.play();
      },
      childWidget: application, feedback: () {  },);

    var timer = Timer(Duration(milliseconds: 1), () {

    });

    draggableWindow.setListener((){

      if(!timer.isActive && draggableWindow.isCrashed){
        timer = Timer(Duration(milliseconds: 50), () {
          draggableWindow.getScreenShotWidget().then((value)
          {
            windows.insert(1,value);
            onUpdate();
          }
          );
        });
      }


      windows.remove(draggableWindow);

      windows.insert(0, draggableWindow);

      onUpdate();

    });


    draggableWindow.childWidget.setListener(WindowListener(
      onClose: (window){
        windows.remove(draggableWindow);
        onUpdate();
      },
      onAppCrash: (_){
        draggableWindow.isCrashed= true;
        draggableWindow.childWidget.canResize = false;
        draggableWindow.getScreenShotWidget().then((value)
        {

          windows.insert(1,value);
          onUpdate();
        }
        );

        assetsAudioPlayer.play();
      }

    ));


    windows.insert(0,draggableWindow);

    onUpdate();

  }


}