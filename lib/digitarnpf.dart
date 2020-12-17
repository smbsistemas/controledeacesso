import 'dart:convert';
//import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:grouped_buttons/grouped_buttons.dart';

//import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

//class NaoConforme extends StatelessWidget  {
class DigitaNPF extends StatefulWidget {
  @override
  _DigitaNPF createState() => new _DigitaNPF();
}

class _DigitaNPF extends State<DigitaNPF> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;

  String wPorta = '8080';
  String wHost = '100.68.70.101';

  String _npf;

  final String dataNPF =
      '{"Socio":[{"CODIGO":"656849","NOME":"ROGERIO PETER","MENSAGEM":"LIBERADO"}]}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.all(15.0),
          child: new Form(
            key: _key,
            autovalidate: _validate,
            child: _formUI(),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    return new Column(
      children: <Widget>[
        // Texto não conformidade
        new TextFormField(
          decoration: new InputDecoration(hintText: 'Informe o NPF:'),
          maxLength: 100,
          validator: _validarTexto,
          onSaved: (String val) {
            _npf = val;
          },
        ),

        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Enviar'),
        )
      ],
    );
  }

  String _validarTexto(String value) {
    String patttern = r'(\-0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o Texto";
    } else if (!regExp.hasMatch(value)) {
      return "Informe apenas numeros";
    }
    return null;
  }

  void _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      // print(selectedClassificacao);
      _pesquisaSocio();
      _key.currentState.save();
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  void _pesquisaSocio() async {
    if (_npf != null) {
      var dataNPF = await http.get('http://$wHost:$wPorta/PesqSocio/$_npf');

      var jsonData = json.decode(dataNPF.body)['Socio'];

      List<Socio> _listSocio = [];
      int x = 0;

      for (var u in jsonData) {
        Socio documento = Socio(x, u['CODIGO'], u['NOME'], u['MENSAGEM']);
        _listSocio.add(documento);
        x = x + 1;
      }
      _npf = _listSocio[0].codSocio;
      _showAlertDialog(context);
      print(_listSocio[0].codSocio);
    } else {
      print("erro: valores null - send novamente");
    }
  }

  Future _showAlertDialog(BuildContext context) async {
    Alert(
      context: context,
      // type: AlertType.warning,
      title: "SOCIO NÃO CADASTRADO",
      desc: "Código: $_npf",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }
}

// Para retornar arquivo do celular para gravar JSON
// Pega o diretorio onde posso armazenar no meu app
// qualquer informação

// Criar o arquivo para Não Conformidade

class Socio {
  final int index;
  final String codSocio;
  final String nomeSocio;
  final String socioMensagem;

  Socio(this.index, this.codSocio, this.nomeSocio, this.socioMensagem);
}
