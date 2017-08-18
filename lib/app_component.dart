// Copyright (c) 2017, Martin Vylet. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

//KNOWN ISSUE: when editting, if entered < 2 words, form will hide and cannot be repaired, original entry is not edited

import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';
import 'package:queries/collections.dart';
import 'dart:html';
import 'dart:convert';


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
  var radioEng = false;
  var radioGer = false;
  var radioFin = false;
  var radioRom = false;
  var radioCze = false;
  
  //delete inputs
  var deleteInput;
  
  List<String> deleteSelect = new List();  
  var deleteSelected;
  
  var submittedDelete = false;

  //edit stuff
  var editInput;
  
  List<String> editSelect = new List();
  var editSelected;
  
  var editEnglish;
  var editGerman;
  var editFinnish;
  var editRomanian;
  var editCzech;
  
  bool submitted = false;
  bool editConfirmed = false;
   
   editEntry()
   {
		if (editInput == null || editInput == "") {
			var element = querySelector('#error');
			element.text = 'Please fill a word you want to edit!';
			errorDialog = true;
			return;
		}
		List<Lang> results = search(editInput.toString().trim());
		if (results.length == 0){
			editConfirmed = false;
			submitted = false;
			var element = querySelector('#error');
			element.text = 'Not found!';
			errorDialog = true;
			return;
		}
		editSelect.clear();
		for (var v in results)
		{
			var line = v.Eng + "; " + v.Ger + "; " + v.Fin + "; " + v.Rom + "; " + v.Cze;
			editSelect.add(line);
			if( editSelect.length >=0);
				editSelected = editSelect[0];
		}
	   
   
   }
   
   onEditConfirm()
   {
	   if (editSelected == null || editSelected == "")
	   {
		   return;
	   }
	   var splitted = editSelected.split(";");
	   for (var v in splitted)
		   v = v.trim();
		
		if (splitted.length < 4)
			return;
		editEnglish = splitted[0];
		editGerman = splitted[1];
		editFinnish = splitted[2];
		editRomanian = splitted[3];
		if(splitted.length == 5)
			editCzech = splitted[4];
		else
			editCzech = "";
   }
   
   editSave()
   {
		if(add(editEnglish,editGerman,editFinnish,editRomanian,editCzech))
		{
			
			if(!delete1(editSelected))
				print("nodopice");
			var element = querySelector('#success');
			element.text = 'Entry succesfully edited!';
			successDialog = true;
			nullEditForm();
		}
		
  }

   nullAddForm()
   {
    english = "";
    german = "";
    finnish = "";
    romanian = "";
    czech = "";
   }
    nullEditForm()
	{
		editEnglish = "";
		editGerman = "";
		editFinnish = "";
		editRomanian = "";
		editCzech = "";
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

  add(var e, var g, var f, var r, var c)
  {
	var inputCount = 0;
	if(e != "")
		inputCount++;
	if(g != "")
		inputCount++;
	if(f != "")
		inputCount++;
	if(r != "")
		inputCount++;
	if(c != "")
		inputCount++;
	
    if (inputCount < 2) {
      var element = querySelector('#error');
      element.text = 'Please fill at least 2 languages!';
      errorDialog = true;
      return false;
    }
    Lang newL = new Lang(e, g, f, r, c,(e + " - " + g + " - " + f + " - " + r + " - " + c));
    if (!dataContains(newL))
	{
		data.add(newL);
	}
	return true;
  }
  
  addNewEntry() {
	
	if(add(english,german,finnish,romanian,czech))
	{
		
		var element = querySelector('#success');
		element.text = 'Entry succesfully added!';
		successDialog = true;
		nullAddForm();
	}
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

  searchEntries() {
    if (searchInput == null || searchInput == "") {
      var element = querySelector('#error');
      element.text = 'Please fill a word you want to search!';
      errorDialog = true;
      return;
    }
	List<Lang> results = search(searchInput.toString().trim());
    if (results.length == 0){
      var element = querySelector('#error');
      element.text = 'Not found!';
      errorDialog = true;
	  return;
    }
    generateTable(results);
  }

  search(String x) //returns List<Lang> od results found in database
  {
	
    List<Lang> results = new List();
    for (var v in data) {
      if (radioEng)
        if(v.Eng == x)
          results.add(v);
      if (radioGer)
        if(v.Ger == x)
          results.add(v);
      if (radioFin)
        if(v.Fin == x)
          results.add(v);
      if (radioRom)
        if(v.Rom == x)
          results.add(v);
      if (radioCze)
        if(v.Cze == x)
          results.add(v);
    }
	
	return results;
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
	List<Lang> results = search(deleteInput.toString().trim());
	if (results.length == 0){
		var element = querySelector('#error');
		element.text = 'Not found!';
		errorDialog = true;
		return;
	}
	deleteSelect.clear();
	for (var v in results)
	{
		var line = v.Eng + "; " + v.Ger + "; " + v.Fin + "; " + v.Rom + "; " + v.Cze;
		deleteSelect.add(line);
		if( deleteSelect.length >=0);
			deleteSelected = deleteSelect[0];
	}
	   
   
  }
  
  onDeleteConfirm()
  {
	 if (deleteSelected == null || deleteSelected == "")
	 {
		return;
	 }
	 if(delete1(deleteSelected))
	 {
		var element = querySelector('#success');
		element.text = 'Entry succesfully deleted!';
		successDialog = true;
	 }
  }
  
  delete1(String x)
  {
	
	var found = false;
	for (var v in data) 
	{
		var toDelete = v.Eng + "; " + v.Ger + "; " + v.Fin + "; " + v.Rom + "; " + v.Cze;
        if(toDelete == x)
		{
			found = true;
			data.remove(v);
			break;
		}	
    }
	return found;
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
      Lang newEntry = new Lang(splitted2nd[0], splitted2nd[1], splitted2nd[2], splitted2nd[3], splitted2nd[4], (splitted2nd[0]+" - "+ splitted2nd[1]+ " - " +splitted2nd[2]+" - "+splitted2nd[3]+" - " +splitted2nd[4]));
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



class Lang implements HasUIDisplayName  {
  String Eng;
  String Ger;
  String Fin;
  String Rom;
  String Cze;
  String label;
  
  Lang(this.Eng, this.Ger, this.Fin, this.Rom, this.Cze, this.label);
  
    @override
  String get uiDisplayName => label;

  @override
  String toString() => uiDisplayName;
}




