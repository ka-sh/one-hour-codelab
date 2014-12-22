// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math' show Random;
import 'dart:convert' show JSON;
import 'dart:async' show Future;
ButtonElement generateNamebtn = querySelector('#generateButton');
final String TREASURE_KEY='pirateName';
SpanElement badgeSpanElement;

void main() {
  InputElement inputField = querySelector('#inputName');
  inputField.onInput.listen(updateBadge);
  ButtonElement generateButton = querySelector('#generateButton');
  generateButton.onClick.listen(generateName) ;
  badgeSpanElement = querySelector('#badgeName');
  PirateName.readyThePirates().then((_) {
    //On success
    inputField.disabled = false;
    generateButton.disabled = false;
    setBadgeText(getBadgeNameFromStorage());
  }).catchError((arrr){
    print('Error while intializing pirate names:$arrr');
    badgeSpanElement.text = 'Arrr! No names.';
  });
  
}

void updateBadge(Event e) {
  String text = (e.target as InputElement).value;
  if (text.trim().isEmpty) {
    generateNamebtn
        ..disabled = false
        ..text = "Ayee generate a name";
  } else {
    generateNamebtn
        ..disabled = true
        ..text = "Arr write your name";
  }
  setBadgeText(new PirateName(firstName: text));
}

void generateName(Event e) {
  setBadgeText(new PirateName());
}

void setBadgeText(PirateName pirateName) {
  if(pirateName == null){return;}
  window.localStorage[TREASURE_KEY]=pirateName.jsonString;
  querySelector('#badgeName').text = pirateName.pirateName;
}

PirateName getBadgeNameFromStorage(){
  String storedName = window.localStorage[TREASURE_KEY];
  if(storedName!=null){
    return new PirateName.fromJson(storedName);
  }else{
    return null;
  }
}

class PirateName {
  static final Random indexGen = new Random();
  String _firstName;
  String _appellation;

  static  List<String> names = [];
  static  List<String> appellations = [];
 
  static Future readyThePirates(){
   return  HttpRequest.getString("names.json").then(_parsePirateNames);
  }
  static _parsePirateNames(String jsonStr){
    Map decoded = JSON.decode(jsonStr);
    names = decoded['names'];
    appellations = decoded['appellations'];
  }
  PirateName.fromJson(String jsonStr) {
    Map storedName = JSON.decode(jsonStr);
    _firstName = storedName['f'];
    _appellation = storedName['a'];
  }


  PirateName({String firstName, String appellation}) {
    if (firstName == null) {
      _firstName = names[indexGen.nextInt(names.length)];
    } else {
      _firstName = firstName;
    }
    if (appellation == null) {
      _appellation = names[indexGen.nextInt(names.length)];
    } else {
      _appellation = appellation;
    }
  }
  
  String get jsonString => JSON.encode({
    "f": _firstName,
    "a": _appellation
  });
  
  String get pirateName => _firstName.isEmpty ? ' ' : '$_firstName the $_appellation';

  String toString() => pirateName;

}
