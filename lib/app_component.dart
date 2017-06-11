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
  directives: const [CORE_DIRECTIVES,
                    materialDirectives,
                    ModalComponent,
                    MaterialDialogComponent,
                    MaterialRadioComponent,
                    MaterialRadioGroupComponent,
  ],
  providers: const [materialProviders],
)



class AppComponent implements OnInit {

  List<String> languages = ["English", "German", "Finnish", "Romanian"];
  List<String> data = new List();
  String entry = "";


  var english;
  var german;
  var finnish;
  var romanian;
  var errorDialog;
  var successDialog;
  var infoDialog;

  var searchInput;
  var radioSearchEng;
  var radioSearchGer;
  var radioSearchFin;
  var radioSearchRom;

  addNewEntry() {
    entry = "";
    if (english == null || german == null || finnish == null || romanian == null ||
        english == "" || german == "" || finnish == "" ||romanian == "") {
      var element = querySelector('#error');
      element.text = 'Please fill all fields!';
      errorDialog = true;
      return;
    }
    entry += (english.toString().trim() + ";") ;
    entry += (german.toString().trim() + ";") ;
    entry += (finnish.toString().trim() + ";") ;
    entry += (romanian.toString().trim() + ";") ;
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

  search() {
    var indexOfSearch;
    if (radioSearchEng)
      indexOfSearch = 0;
    else if (radioSearchGer)
      indexOfSearch = 1;
    else if (radioSearchFin)
      indexOfSearch = 2;
    else if (radioSearchRom)
      indexOfSearch = 3;
    if (searchInput == null || searchInput == "") {
      var element = querySelector('#error');
      element.text = 'Please fill a word you want to search!';
      errorDialog = true;
      return;
    }
    List<String> results = new List();
    for (var v in data) {
      var sp = v.split(";");
      if (sp[indexOfSearch] == searchInput.toString().trim())
        results.add(v);
        //results.add("English: " + sp[0] + ", German: " + sp[1] + ", Finnish: " + sp[2] + ", Romanian: " + sp[3]);
    }
    if (results.length == 0){
      var element = querySelector('#error');
      element.text = 'Not found!';
      errorDialog = true;
      return;
    }

    generateTable(results);

    return;
  }

  showAll(){
    generateTable(data);
  }

  void generateTable(List<String> results) {
    var output = querySelector('#showResultsOfSearch');
    output.nodes.clear();
    var table = new Element.tag('table');
    table.style.width = "100%";
    table.style.border = "1px solid black";
    table.style.borderCollapse = "collapse";
    table.nodes.clear();
    var tableWrapper = new Element.tag('tr');
    tableWrapper.nodes.clear();


    for(int i = 0; i < 4; i++) {
      var tableH = new Element.th();
      tableH.style.border = "1px solid black";
      tableH.style.borderCollapse = "collapse";
      tableH.style.padding = "5px";
      tableH.style.color = "rgb(77, 144, 254)";
      tableH.text = languages[i];
      tableWrapper.nodes.add(tableH);

    }
    table.nodes.add(tableWrapper);

    for (var v in results){
      var tableWrapper = new Element.tag('tr');
      var split = v.split(";");
      split.removeLast();
      for(var x in split){
        var tableI = new Element.tag('td');
        tableI.style.border = "1px solid black";
        tableI.style.borderCollapse = "collapse";
        tableI.style.padding = "5px";
        tableI.text = x;
        tableWrapper.nodes.add(tableI);
      }
      table.nodes.add(tableWrapper);

    }
    output.nodes.add(table);
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




