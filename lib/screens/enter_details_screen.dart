import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/providers/user.dart';
import '../providers/auth.dart';

class EnterDetailsScreen extends StatefulWidget {
  @override
  _EnterDetailsScreenState createState() => _EnterDetailsScreenState();
}

class _EnterDetailsScreenState extends State<EnterDetailsScreen> {
  final _nameFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _contactFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedUser = User(
    id: null,
    name: '',
    contact: '',
    address: '',
  );

  var _initValues = {
    'name': '',
    'contact': '',
    'address': '',
  };

  var _isInit = true;
  var _isLoading = false;

  void initState() {
    super.initState();
  }

  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Auth>(context).fetchAndSetUser().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _editedUser = Provider.of<Auth>(context, listen: false).user;
      if (_editedUser != null) {
        _initValues = {
          'name': _editedUser.name,
          'contact': _editedUser.contact,
          'address': _editedUser.address,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void dispose() {
    _nameFocusNode.dispose();
    _contactFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedUser.id != null) {
      print('editing');
      await Provider.of<Auth>(context, listen: false)
          .updateUser(_editedUser.id, _editedUser);
    } else {
      try {
        await Provider.of<Auth>(context, listen: false).addUser(_editedUser);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured'),
            content: Text('Something went wrong'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).popAndPushNamed('/products-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Please enter your details'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        // child: Column(
        //   children: <Widget>[
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        initialValue: _initValues['name'],
                        decoration: InputDecoration(labelText: 'Name'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_contactFocusNode);
                        },
                        focusNode: _nameFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedUser = User(
                            id: _editedUser.id,
                            name: value,
                            contact: _editedUser.contact,
                            address: _editedUser.address,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        initialValue: _initValues['contact'],
                        decoration: InputDecoration(labelText: 'Contact'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_addressFocusNode);
                        },
                        focusNode: _contactFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid phone number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedUser = User(
                            id: _editedUser.id,
                            name: _editedUser.name,
                            contact: value.toString(),
                            address: _editedUser.address,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        initialValue: _initValues['address'],
                        decoration: InputDecoration(labelText: 'Address'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        focusNode: _addressFocusNode,
                        onFieldSubmitted: (_) {},
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide your address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedUser = User(
                            id: _editedUser.id,
                            name: _editedUser.name,
                            contact: _editedUser.contact,
                            address: value,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      child: ButtonTheme(
                        height: MediaQuery.of(context).size.height * 0.08,
                        minWidth: 20,
                        child: RaisedButton.icon(
                          label: Text('Submit'),
                          icon: Icon(Icons.save),
                          color: Theme.of(context).primaryColor,
                          onPressed: saveForm,
                        ),
                      ),
                    )
                  ],
                ),
              ),
        // FlatButton.icon(
        //   icon: Icon(Icons.save),
        //   label: Text('Save'),
        //   onPressed: () {
        //     Navigator.of(context).pushNamed('/products-screen');
        //   },
        // )
        // ],
        // ),
      ),
    );
  }
}