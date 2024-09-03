import 'package:flutter/material.dart';
import 'package:sinapse/database.dart';
import 'models/Materia.dart';
import 'models/Usuario.dart';
import 'user_manager.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  Future<void> _login() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      List<Usuario> usuarios = await Usuario.getUsuarios();

      Usuario? foundUser = usuarios.firstWhere(
            (usuario) => usuario.email == _email,
        orElse: () => Usuario(nome: '', email: ''), // Retorna um usuário vazio
      );

      if (foundUser.email == _email) {
        // Verifica se o email corresponde ao encontrado
        UserManager.userId = foundUser.id; // Armazena o ID do usuário
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não encontrado')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Registrar-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
