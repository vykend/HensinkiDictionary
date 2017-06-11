// Copyright (c) 2017, Martin. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';
import 'package:queries/collections.dart';
import 'dart:html';
//import 'dart:io';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [CORE_DIRECTIVES, materialDirectives, ModalComponent, MaterialDialogComponent],
  providers: const [materialProviders],
)



class AppComponent implements OnInit {

  List<String> data = new List();
  String entry = "";


  var english;
  var german;
  var finnish;
  var romanian;
  var errorDialog;
  var successDialog;
  var infoDialog;

  addNewEntry() {
    entry = "";
    if (english == null || german == null || finnish == null || romanian == null ||
        english == "" || german == "" || finnish == "" ||romanian == "") {
      var element = querySelector('#error');
      element.text = 'Please fill all fields!';
      errorDialog = true;
      return;
    }
    entry += (english.toString() + ";") ;
    entry += (german.toString() + ";") ;
    entry += (finnish.toString() + ";") ;
    entry += (romanian.toString() + ";") ;
    data.add(entry);
    data = new Collection(data).distinct().toList(); //remove duplicities
    var element = querySelector('#success');
    element.text = 'Entry succesfully added!';
    successDialog = true;
    english = null;
    german = null;
    finnish = null;
    romanian = null;
  }

  download() async {
    if (data.isEmpty)
    {
      var element = querySelector('#error');
      element.text = 'Dictionary is empty!';
      errorDialog = true;
      return;
    }
    var encodedFileContents = "";
    for (var i in data)
    {
      encodedFileContents += Uri.encodeComponent(i + "\n");
    }
    new AnchorElement(href: "data:text/plain;charset=utf-8,$encodedFileContents")
      ..setAttribute("download", "dictionary.csv")
      ..click();
  }




  //DND CLASS MEMBERS
  FormElement _readForm;
  InputElement _fileInput;
  Element _dropZone;
  OutputElement _output;

  DndFiles() {
    _output = querySelector('#list');
    _readForm = querySelector('#read');
    _fileInput = querySelector('#files_input_element');
    _fileInput.onChange.listen((e) => _onFileInputChange());

    _dropZone = document.querySelector('#drop-zone');
    _dropZone.onDragOver.listen(_onDragOver);
    _dropZone.onDragEnter.listen((e) => _dropZone.classes.add('hover'));
    _dropZone.onDragLeave.listen((e) => _dropZone.classes.remove('hover'));
    _dropZone.onDrop.listen(_onDrop);
  }

  void _onDragOver(MouseEvent event) {
    event.stopPropagation();
    event.preventDefault();
    event.dataTransfer.dropEffect = 'copy';
  }

  void _onDrop(MouseEvent event) {
    event.stopPropagation();
    event.preventDefault();
    _dropZone.classes.remove('hover');
    _readForm.reset();
    _onFilesSelected(event.dataTransfer.files);
  }
  void _onFileInputChange() {
    _onFilesSelected(_fileInput.files);
  }



  void _onFilesSelected(List<File> files) {
      for (var file in files) {
        if (file.name.endsWith('.csv')) {
          final reader = new FileReader();
          reader.onLoad.listen((e) {
            try {
              fillDataFromFile(reader.result);
            }
            catch (x) {
              var element = querySelector('#error');
              element.text = x.toString() + ' in file ' + file.name.toString();
              errorDialog = true;
              return;

            }
          });
          reader.readAsText(file);
        }
        else{
          var element = querySelector('#error');
          element.text = 'File ' + file.name.toString() + " has a wrong format!";
          errorDialog = true;
        }

      }
      var element = querySelector('#info');
      element.text = 'Done reading files!';
      infoDialog = true;

  }


  fillDataFromFile(String x) {
    var splitted = x.split("\n");
    for (var v in splitted) {
      if (v == "")
        continue;
      var splitted2nd = v.split(";");
      if (splitted2nd.length != 5){
        throw new Exception("Wrong data");
      }
      if (splitted != null && !data.contains(v)) {
        data.add(v);
      }
    }
    data = new Collection(data).distinct().toList(); //remove duplicities
  }

    @override
    ngOnInit() {
      DndFiles();
    }
}




