import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileEditScreen extends StatefulWidget {
  final FirebaseUser user;

  ProfileEditScreen(this.user);

  @override
  ProfileEditScreenState createState() => ProfileEditScreenState();
}

class ProfileEditScreenState extends State<ProfileEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  // String _name;
  // String _email;
  String gender;

  bool genderMale = false;
  bool genderFemale = false;
  bool genderOthers = false;

  Map<String,String> _bioData = {
    'name': '',
    'gender':'',
    'bio':'',
    'dob':'',
  };
  final _bioController = TextEditingController();
  final _dobController = TextEditingController();

  void dispose() {
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }
 // if()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: new SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.blueAccent.withOpacity(0.7),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  new Container(
                    margin: new EdgeInsets.all(15.0),
                    child: new Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: FormUI(),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: MediaQuery.of(context).size.width*0.3,
                top: 5,
                child:  Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.user.photoUrl),
                      fit:BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(75)),
                    boxShadow: [
                      BoxShadow(blurRadius: 7,color: Colors.black),],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Here is our Form UI
  Widget FormUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 95),
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: new Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50,right: 10,left: 10),
              child: new TextFormField(
                initialValue: widget.user.displayName,
                decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    )),
                keyboardType: TextInputType.text,
                validator: validateName,
                onSaved: (String val) {
                  _bioData['name'] = val;
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text('Male',style: TextStyle(fontWeight: FontWeight.bold),),
                    Checkbox(
                      value: genderMale,
                      onChanged: (newVal) {
                        setState(() {
                          genderMale = newVal;
                          genderFemale = false;
                          genderOthers = false;
                          gender = newVal ? 'male' : null;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text('Female',style: TextStyle(fontWeight: FontWeight.bold),),
                    Checkbox(
                      value: genderFemale,
                      onChanged: (newVal) {
                        setState(() {
                          genderMale = false;
                          genderFemale = newVal;
                          genderOthers = false;
                          gender = newVal ? 'female' : null;
                          // print(gender);
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text('Others',style: TextStyle(fontWeight: FontWeight.bold),),
                    Checkbox(
                      value: genderOthers,
                      onChanged: (newVal) {
                        setState(() {
                          genderOthers = newVal;
                          genderFemale = false;
                          genderMale = false;
                          gender = newVal ? 'others' : null;
                          print(gender);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              child: FormBuilderDateTimePicker(
                controller: _dobController,
                lastDate: DateTime.now(),
                inputType: InputType.date,
                autovalidate: true,
                initialValue: DateTime.utc(1900),
                format: DateFormat("yyyy-MM-dd"),
                attribute: 'Date of Birth',
                onSaved: (val){
                  print(val);
                  _bioData['dob'] = val.toString();
                },

                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.edit),
                  alignLabelWithHint: false,
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: _bioController,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value.length < 10 ? 'Bio too short.' : null,
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                maxLines: 2,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: 'Tell us about you.',
                  alignLabelWithHint: false,
                  labelText: 'Bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: new RaisedButton(
                  elevation: 5,
                  onPressed: _finaliseSignUp,
                  child: new Text('Update '),
                  color: Theme.of(context).accentColor,
                  textColor:Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }



  void _finaliseSignUp() {
    if (_formKey.currentState.validate()&& gender!=null) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      Navigator.of(context).pushReplacementNamed('/StoredImages');
      Toast.show("Profile Upload Successful", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    } else {
      if(gender==null && _formKey.currentState.validate()){
        Toast.show("Please mark your gender", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }

//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
    _bioData['gender'] = gender;
    _bioData['dob'] = _dobController.text;
    _bioData['bio']= _bioController.text;
    print(_bioData);
    createRecord();
  }
  void createRecord(){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child(widget.user.uid).set(
        _bioData
    );
  }
}