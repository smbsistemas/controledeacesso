import 'dart:io';
import 'dart:convert';

import 'package:controle_acesso/infra/portaria.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:controle_acesso/qr_barcode_screen.dart';
import 'theme.dart' as Theme;

import 'package:controle_acesso/infra/data.dart';

/*

Minas 1
IP: 177.85.84.69 ---> 172.16.0.4 : Porta 9099

Minas 2
IP: 177.85.84.81 ---> 172.16.64.3 : Porta 9099

Country
IP: 177.85.84.110 ---> 172.16.128.4 : Porta 9099

Náutico
IP: 177.85.84.120 ---> 172.16.192.3 : Porta 9099

*/

class API {
  static Future getPortaria(String phost, String pporta) async {
    var url = "http://$phost:$pporta/GetPortaria";
    var dataPortaria = await http.get(url);
    return dataPortaria;
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final data = Data();
  final _formKey = GlobalKey<FormState>();

  String _porta = '9099'; // porta liberada pelo Alan
  String _host = '177.85.84.69'; // servntportm1 - Acesso Externo

  String _password;
  String _user;
  String _idUnidade;
  String _unidade;
  String _idPortaria;
  String _idDispositivo;
  String _portaria;
  String _idMatricula;
  String _itemPortaria;

  var _portariaList = new List<Portaria>();

  List _acessoUserList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _getPortaria();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [
                        Theme.Colors.loginGradientStart,
                        Theme.Colors.loginGradientEnd
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                padding: EdgeInsets.all(20.0),
                child:
                    Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  SizedBox(height: 80.0),
                  Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffFFFFFF),
                        border: Border.all(
                          color: Colors.white,
                          width: 40,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Form(
                          key: _formKey,
                          child: Column(children: <Widget>[
                            SizedBox(height: 20.0),
                            Text(
                              'Controle de Acesso',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20.0),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Portaria:  ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Row(children: <Widget>[
                              DropdownButtonHideUnderline(
                                child: new DropdownButton<String>(
                                  hint: new Text("Selecione Portaria"),
                                  isDense: true,
                                  items: _portariaList.map((Portaria map) {
                                    return new DropdownMenuItem<String>(
                                      value: map.portariaDescricao,
                                      child: new Text(map.portariaDescricao,
                                          style: new TextStyle(
                                              color: Colors.black)),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      _itemPortaria = newValue;
                                    });
                                  },
                                  value: _itemPortaria,
                                ),
                              ),
                            ]),
                            SizedBox(height: 20.0),
                            SizedBox(height: 20.0),
                            TextFormField(
                                onSaved: (value) => _user = value,
                                maxLength: 50,
                                keyboardType: TextInputType.name,
                                decoration:
                                    InputDecoration(labelText: "Login")),
                            TextFormField(
                                onSaved: (value) => _password = value,
                                obscureText: true,
                                maxLength: 50,
                                decoration:
                                    InputDecoration(labelText: "Senha")),
                            SizedBox(height: 20.0),
                            RaisedButton(
                                child: Text("Enviar"),
                                onPressed: () async {
                                  if (_itemPortaria == null) {
                                    _showAlertDialog(context);
                                  } else {
                                    // save the fields..
                                    final form = _formKey.currentState;
                                    form.save();

                                    // Validate will return true if is valid, or false if invalid.
                                    if (form.validate()) {
                                      var result = await _validaAcesso();
                                      if (result != null) {
                                        print(
                                            'chamada da rotina de QrBarCodeScreen');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QRBarcodeScreen(data: data)),
                                        );
                                      } else {
                                        return _buildShowErrorDialog(
                                            context, "Acesso negado!");
                                      }
                                    }
                                  }
                                })
                          ])))
                ]))));
  }

  Future _buildShowErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Mensagem de erro:'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancelar'),
                onPressed: () {
                  return null;
                })
          ],
        );
      },
      context: context,
    );
  }

  _validaAcesso() async {
    print('Cheguei ! - Save');
    print('host: $_host');
    print('porta: $_porta');
    print('_itemPortaria: $_itemPortaria');
    print('usuario: $_user');
    print('senha: $_password');

    String _mensagem = 'NEGADO';
    try {
      var url =
          'http://$_host:$_porta/GetValidaUsuario/$_itemPortaria/$_user/$_password';
      var dataValidaAcesso = await http.get(url);
      var jsonData = json.decode(dataValidaAcesso.body)['GetValUsua'];
      List<Login> _loginPage = [];
      int x = 0;
      for (var u in jsonData) {
        Login documento = Login(
            x,
            u['COD_UNIDADE'],
            u['UNIDADE'],
            u['COD_PORTARIA'],
            u['PORTARIA'],
            u['DISPOSITIVO'],
            u['MATRICULA'],
            u['MENSAGEM']);
        _loginPage.add(documento);
        x = x + 1;
      }

      _idUnidade = _loginPage[0].lpCodUnidade;
      _unidade = _loginPage[0].lpUnidade;
      _idPortaria = _loginPage[0].lpCodPortaria;
      _portaria = _loginPage[0].lpPortaria;
      _idMatricula = _loginPage[0].lpMatricula;
      _mensagem = _loginPage[0].lpMensagem;
      _idDispositivo = _loginPage[0].lpDispositivo;

      if (_idUnidade == '2') {
        // Minas 2
        _host = '177.85.84.81';
      } else if (_idUnidade == '3') {
        // Nautico
        _host = ' 177.85.84.120';
      } else if (_idUnidade == '4') {
        // Country
        _host = '177.85.84.110';
      }

      data.idUnidade = _idUnidade;
      data.unidade = _unidade;
      data.idPortaria = _idPortaria;
      data.portaria = _portaria;
      data.idDispositivo = _idDispositivo;
      data.idMatricula = _idMatricula;
      data.idHost = _host;
      data.idPorta = _porta;

      print('Mensagem: $_mensagem');
      if (_mensagem == 'LIBERADO') {
        return _mensagem;
      } else {
        return null;
      }
    } catch (e) {
      print('catch : _mensagem: $_mensagem');
      return null;
    }
  }

  _getPortaria() async {
    API.getPortaria(_host, _porta).then((response) {
      print('_getPortaria: _host: $_host');
      setState(() {
        Iterable list = json.decode(response.body)['Portaria'];
        _portariaList = list.map((model) => Portaria.fromJson(model)).toList();
      });
    });
  }

  _showAlertDialog(BuildContext context) {
    Widget concelarButton =
        FlatButton(child: Text("OK"), onPressed: () => Navigator.pop(context));

    //configura o AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Portaria'),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          Text("Obrigatório selecionar uma portaria!"),
        ],
      )),
      actions: [concelarButton],
    );
    //exibe o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class Login {
  final int index;
  final String lpCodUnidade;
  final String lpUnidade;
  final String lpCodPortaria;
  final String lpPortaria;
  final String lpDispositivo;
  final String lpMatricula;
  final String lpMensagem;
  Login(this.index, this.lpCodUnidade, this.lpUnidade, this.lpCodPortaria,
      this.lpPortaria, this.lpDispositivo, this.lpMatricula, this.lpMensagem);
}
