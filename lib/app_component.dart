// Copyright (c) 2017, Martin Vylet. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';
import 'package:queries/collections.dart';
import 'dart:html';

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

  
  List<String> languages = ["English", "German", "Finnish", "Romanian", "Czech"];
  List<Lang> data = new List();
  String entry = "";

  //languages
  var english = "";
  var german = "";
  var finnish = "";
  var romanian = "";
  var czech = "";

  //dialogs
  var errorDialog;
  var successDialog;
  var infoDialog = true;

  //search inputs
  var searchInput;
  var radioSearchEng = false;
  var radioSearchGer = false;
  var radioSearchFin = false;
  var radioSearchRom = false;
  var radioSearchCze = false;
  
  //delete inputs
  var deleteInput;
  var radioDeleteEng = false;
  var radioDeleteGer = false;
  var radioDeleteFin = false;
  var radioDeleteRom = false;
  var radioDeleteCze = false;

  
   

  nullAddForm()
  {
    english = "";
    german = "";
    finnish = "";
    romanian = "";
    czech = "";
  }

  dataContains(Lang x)
  {
	  for (var v in data)
	  {
		  if (v.Eng == x.Eng && v.Ger == x.Ger && v.Fin == x.Fin && v.Rom == x.Rom && v.Cze == x.Cze)
			  return true;
	  }
	  return false;
  }

  addNewEntry() {
    entry = "";
	var inputCount = 0;
	if(english != "")
		inputCount++;
	if(german != "")
		inputCount++;
	if(finnish != "")
		inputCount++;
	if(romanian != "")
		inputCount++;
	if(czech != "")
		inputCount++;
	
    if (inputCount < 2) {
      var element = querySelector('#error');
      element.text = 'Please fill at least 2 languages!';
      errorDialog = true;
      return;
    }
    Lang newL = new Lang(english, german, finnish, romanian, czech);
    if (!dataContains(newL))
	{
		data.add(newL);
	}
	
    var element = querySelector('#success');
    element.text = 'Entry succesfully added!';
    successDialog = true;
    nullAddForm();
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
      encodedFileContents += Uri.encodeComponent(i.Eng + ";" + i.Ger + ";" + i.Fin + ";" + i.Rom + ";" + i.Cze + "\n");
    }
    new AnchorElement(href: "data:text/plain;charset=utf-8,$encodedFileContents")
      ..setAttribute("download", "dictionary.csv")
      ..click();
  }

  search() {
    if (searchInput == null || searchInput == "") {
      var element = querySelector('#error');
      element.text = 'Please fill a word you want to search!';
      errorDialog = true;
      return;
    }
    List<Lang> results = new List();
    for (var v in data) {
      if (radioSearchEng)
        if(v.Eng == searchInput.toString().trim())
          results.add(v);
      if (radioSearchGer)
        if(v.Ger == searchInput.toString().trim())
          results.add(v);
      if (radioSearchFin)
        if(v.Fin == searchInput.toString().trim())
          results.add(v);
      if (radioSearchRom)
        if(v.Rom == searchInput.toString().trim())
          results.add(v);
      if (radioSearchCze)
        if(v.Cze == searchInput.toString().trim())
          results.add(v);
    }
    if (results.length == 0){
      var element = querySelector('#error');
      element.text = 'Not found!';
      errorDialog = true;
    }

    generateTable(results);

    return;
  }

  showAll(){
    generateTable(data);
  }

  void generateTable(List<Lang> results) {
    var output = querySelector('#showResultsOfSearch');
    output.nodes.clear();
    var table = new Element.tag('table');
    table.style.width = "100%";
    table.style.border = "1px solid black";
    table.style.borderCollapse = "collapse";
    table.nodes.clear();
    var tableWrapper = new Element.tag('tr');
    tableWrapper.nodes.clear();

    //header
    for(int i = 0; i < 5; i++) {
      var tableH = new Element.th();
      tableH.style.border = "1px solid black";
      tableH.style.borderCollapse = "collapse";
      tableH.style.padding = "5px";
      tableH.style.color = "rgb(77, 144, 254)";
      tableH.text = languages[i];
      tableWrapper.nodes.add(tableH);

    }
    table.nodes.add(tableWrapper);

    //rows
    for (var v in results){
      var tableWrapper = new Element.tag('tr');

      for (var i = 0; i < 5; i++) {
        var tableI = new Element.tag('td');
        tableI.style.border = "1px solid black";
        tableI.style.borderCollapse = "collapse";
        tableI.style.padding = "5px";
        if (i == 0)
          tableI.text = v.Eng;
        else if (i == 1)
          tableI.text = v.Ger;
        else if (i == 2)
          tableI.text = v.Fin;
        else if (i == 3)
          tableI.text = v.Rom;
        else if (i == 4)
          tableI.text = v.Cze;
        tableWrapper.nodes.add(tableI);
      }
      table.nodes.add(tableWrapper);

    }
    output.nodes.add(table);
  }

  
  deleteEntry()
  {
	 if (deleteInput == null || deleteInput == "") {
      var element = querySelector('#error');
      element.text = 'Please fill a word you want to delete!';
      errorDialog = true;
      return;
    }
	var found = false;
	for (var v in data) {
      if (radioDeleteEng)
	  {
        if(v.Eng == deleteInput.toString().trim())
		{
			found = true;
			data.remove(v);
			break;
		}		  
	  }
      if (radioDeleteGer)
	  {
        if(v.Ger == deleteInput.toString().trim())
		{
			found = true;
			data.remove(v);
			break;
		}		  
	  }
      if (radioDeleteFin)
	  {
        if(v.Fin == deleteInput.toString().trim())
		{
			found = true;
			data.remove(v);
			break;
		}		  
	  }
      if (radioDeleteRom)
	  {
        if(v.Rom == deleteInput.toString().trim())
		{
			found = true;
			data.remove(v);
			break;
		}		  
	  }
      if (radioDeleteCze)
	  {
        if(v.Cze == deleteInput.toString().trim())
		{
			found = true;
			data.remove(v);
			break;
		}		  
	  }
    }
	
    if(!found) {
	  var element = querySelector('#error');
	  element.text = 'Not found!';
	  errorDialog = true;
	  return;
	}
	else
	{
	  var element = querySelector('#success');
      element.text = deleteInput.toString().trim() + ' succesfully removed!';
      successDialog = true;
	}
	
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
		  return;
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
      Lang newEntry = new Lang(splitted2nd[0], splitted2nd[1], splitted2nd[2], splitted2nd[3], splitted2nd[4]);
      if (splitted != null && !dataContains(newEntry)) {
        data.add(newEntry);
      }
    }
  }

    @override
    ngOnInit() {
      DndFiles();
    }
}



class Lang {
  String Eng;
  String Ger;
  String Fin;
  String Rom;
  String Cze;

  Lang(this.Eng, this.Ger, this.Fin, this.Rom, this.Cze);
}




