import 'package:flutter/material.dart';
import 'package:grocery_app_dio/screens/grocery_list.dart';
import 'package:grocery_app_dio/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredPassword = '';

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }

  void _checkLogin() async {
    String? token = await AuthService().getToken();
    if(token != null){
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) => GroceryList()));
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      try{
        final authService = AuthService();
        String? token = await authService.login(_enteredName, _enteredPassword);

        if(token == null) {
          // Display Error
        }
        if(token != null){
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (ctx) => GroceryList()));
        }
      }catch(ex){
        print(ex.toString());
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Here")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(label: const Text("Username")),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(label: const Text("Password")),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredPassword = value!;
                },
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: Text("Reset"),
                  ),
                  ElevatedButton(onPressed: _login, child: Text("Login")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
