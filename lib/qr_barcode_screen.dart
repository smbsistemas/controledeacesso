import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
//import 'package:qr_flutter/qr_flutter.dart';

import 'bubble_indication_painter.dart';
import 'theme.dart' as Theme;

import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert';

import 'package:controle_acesso/infra/data.dart';

class QRBarcodeScreen extends StatefulWidget {
  final Data data;

  QRBarcodeScreen({this.data, Key key}) : super(key: key);

  @override
  _QrBarcodeState createState() => new _QrBarcodeState(data: data);
}

class _QrBarcodeState extends State<QRBarcodeScreen>
    with SingleTickerProviderStateMixin {
  final Data data;
  _QrBarcodeState({this.data});

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode mFocusNodeQrValue = FocusNode();
  TextEditingController qrController = new TextEditingController();
  PageController _pageController;
  Color left = Colors.black;
  Color right = Colors.white;
  GlobalKey globalKey = new GlobalKey();
  final TextEditingController _textController = TextEditingController();
  String _idUnidade = '';
  String _idPortaria = '';
  String _idMatricula = '';
  String _unidade = '';
  String _portaria = '';
  String _idDispositivo = '';
  String _qrAtendente = '';

  String _qrInfo = 'Ler QR code';
  String _qrInfo_old = 'xxxxxxx';

  bool _validate = false;

  // String wPorta = '9099';

  List<Socio> _listSocio = [];
  List<Registro> _listRegistro = [];
  List<FotoSocio> _listFotoSocio = [];

  //String wHost = '172.16.1.117'; // Ip Externo - Servntportm1 (172.16.0.4)
  //String wHost = '177.74.233.5'; // Ip Externo - Servntportm1 (172.16.0.4)
  // String _host = '177.85.84.69';
  // String _porta = '9099';
  String _host = '';
  String _porta = '';

  GlobalKey<FormState> _key = new GlobalKey();

  String _npf_lido = '999999';
  String _socioNPF = '';
  String _socioNome = '';
  String _socioRestricao = '';
  String _socioCodRestricao = '';
  String _socioMensagem = '';
  String _qteSocios = '';

  final String dataNPF = '';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) {
                    if (i == 0) {
                      setState(() {
                        right = Colors.white;
                        left = Colors.black;
                      });
                    } else if (i == 1) {
                      setState(() {
                        right = Colors.black;
                        left = Colors.white;
                      });
                    }
                  },
                  children: <Widget>[
                    _buildScan(context),
                    _informarNPF(context),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.0, bottom: 50),
                child: _buildMenuBar(context),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
          decoration: new BoxDecoration(color: Color(0xFF026bbb)),
          child: IconButton(
              icon: Text('1.01'),
//              icon: Icon(
//                Icons.person,
//              ),
              onPressed: () {
                setState(() {
                  // chamado do programa de Login
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => LoginPage()),
                  //     );
                });
              })),
    );
  }

  @override
  void dispose() {
    mFocusNodeQrValue.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _idUnidade = this.data.idUnidade;
    _unidade = this.data.unidade;
    _idPortaria = this.data.idPortaria;
    _portaria = this.data.portaria;
    _idMatricula = this.data.idMatricula;
    _idDispositivo = this.data.idDispositivo;
    _host = this.data.idHost;
    _porta = this.data.idPorta;
    print('qr_barcode - idUnidade: $_idUnidade');
    print('qr_barcode - host: $_host');
    print('qr_barcode - porta: $_porta');

    _pageController = PageController();
    // print('un: $_idUnidade po: $_idPortaria Ma: $_idMatricula ');
    _qrAtendente =
        'Unidade: $_idUnidade  Portaria :$_portaria Matricual($_idMatricula)';
  }

  Widget _buildMenuBar(BuildContext context) {
    // print('Uniddade: $_idUnidade');
    // print('portaria: $_idPortaria');
    // print('matricula: $_idMatricula');
    // print('unidade: $_unidade');
    // print('portaria: $_portaria');
    // print('dispositivo: $_idDispositivo');

    //  _qrAtendente = '($_idUnidade) - $_unidade - $_portaria - ($_idMatricula) ';

    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onScanButtonPress,
                child: Text(
                  "QR code",
                  style: TextStyle(
                    color: left,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onGenerateButtonPress,
                child: Text(
                  "Registrar Saida",
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenButton(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {});
        },
        child: Container(
          width: 150.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: Theme.Colors.loginGradientEnd,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          child: Center(
            child: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ));
  }

  _qrCallback(String code) {
    setState(() {
      _qrInfo = code;
      print(code);
      _pesquisaSocioQrCode();
    });
  }

  Widget _buildScan(BuildContext context) {
    return Center(
      child: Card(
          elevation: 2.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: 300,
            height: 500,
            child: Column(
              children: <Widget>[
                Container(
                  // color: Colors.amber[600],
                  child: Text(
                    'Controle de Acesso',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  width: 360.0,
                  height: 100.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 20),
                ),
                Container(
                  height: 300,
                  width: 280,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: QRBarScannerCamera(
                    onError: (context, error) => Text(
                      error.toString(),
                      style: TextStyle(color: Colors.red),
                    ),
                    qrCodeCallback: (code) {
                      _qrCallback(code);
                    },
                  ),
                ),
                Text(
                  _qrInfo,
                  style: TextStyle(color: Colors.black26),
                ),
                Text(
                  _qrAtendente,
                  style: TextStyle(color: Colors.black26),
                ),
              ],
            ),
          )),
    );
  }

  //  Widget _buildGen(BuildContext context) {

  Widget _informarNPF(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Center(
      child: Card(
          elevation: 2.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: 300,
            height: 500,
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    'Controle de Acesso',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  width: 360.0,
                  height: 100.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 20),
                ),
                /*           Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                      decoration:
                          new InputDecoration(hintText: 'Informe o NPF:'),
                      maxLength: 10,
                      validator: _validarTexto,
                      onChanged: (String val) {
                        setState(() {
                          _socioNPF = val;
                          print('socioNPF: $_socioNPF');
                        });
                      },
                      onSaved: (String val) {
                        setState(() {
                          _socioNPF = val;
                          print('socioNPF: $_socioNPF');
                        });
                      }),
                ), */
                Container(
                  width: 360.0,
                  height: 100.0,
                  child: TextFormField(
                      controller: _textController,
                      decoration: new InputDecoration(
                          hintText: 'Registrar Saidas - No. de sócios: '),
                      maxLength: 10,
                      //  //  controller: nameHolder,
                      validator: _validarTexto,
                      onChanged: (String val) {
                        setState(() {
                          _qteSocios = val;
                          print('socioNPF: $_socioNPF');
                        });
                      },
                      onSaved: (String val) {
                        setState(() {
                          _qteSocios = val;
                          print('_qteSocios: $_qteSocios');
                        });
                      }),
                ),
                new RaisedButton(
                  //onPressed: null,
                  //   onPressed: _registrarSaidas(),
                  // onPressed: _showAlertRegistrarSaidas(context),
                  child: new Text('Enviar'),
                  onPressed: _registrarMovto,
                )
                //onPressed: _registrarSaidas(context))
              ],
            ),
          )),
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
      _pesquisaSocioQrCode();
      _key.currentState.save();
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  void _pesquisaSocioQrCode() async {
    print('Rotina - _pesquisaSocioQrCode');
    print('Uniddade: $_idUnidade');
    print('portaria: $_idPortaria');
    print('dispositivo: $_idDispositivo');
    print('_qrInfo: $_qrInfo');
    if (_qrInfo != null && _qrInfo != _qrInfo_old) {
      _qrInfo_old = _qrInfo;
      // print('_qrInfo: $_qrInfo');
      var dataNPF = await http.get(
          'http://$_host:$_porta/getValidaQrCode/$_idUnidade/$_idPortaria/$_qrInfo');

      var jsonData = json.decode(dataNPF.body)['ValidaQrCode'];
      int x = 0;
      _listSocio.clear();
      for (var u in jsonData) {
        Socio documento = Socio(x, u['COD_ASSOCIADO'], u['NOME_ASSOCIADO'],
            u['COD_RESTRICAO'], u['RESTRICAO'], u['MENSAGEM']);
        _listSocio.add(documento);
        x = x + 1;
      }
      _socioNPF = _listSocio[0].socioNPF;
      _socioNome = _listSocio[0].socioNome;
      _socioRestricao = _listSocio[0].socioRestricao;
      _socioCodRestricao = _listSocio[0].socioCodRestriccao;
      _socioMensagem = _listSocio[0].socioMensagem;

      print('_npf: $_socioNPF');
      print('_nomeSocio: $_socioNome');
      if (_socioCodRestricao == '99' && _socioNPF != '' && _socioNPF != null) {
        _showAlertDialog2(context);
      } else {
        _showAlertRestricao(context);
      }
    } else {
      print("erro: valores null - send novamente");
    }
  }

  _showAlertDialog2(BuildContext context) {
    Widget concelarButton =
        FlatButton(child: Text("Cancelar"), onPressed: () => _botaoCancelar());

    Widget registrarButton = FlatButton(
        child: Text("Registrar"), onPressed: () => _botaoRegistrar());
    //configura o AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(_socioNome),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          Text("NPF: $_socioNPF"),
          Text('$_socioRestricao'),
          Text(''),
          Text('Mensagem: $_socioMensagem'),
        ],
      )),
      actions: [concelarButton, registrarButton],
    );
    //exibe o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showAlertRestricao(BuildContext context) {
    Widget concelarButton =
        FlatButton(child: Text("OK"), onPressed: () => _botaoCancelar());

    AlertDialog alert = AlertDialog(
      title: Text(_socioNome),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          Text("NPF: $_socioNPF"),
          Text('$_socioRestricao'),
          Text(''),
          Text('Mensagem: $_socioMensagem'),
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

  void _registrarMovto() {
    if (_qteSocios != null && _qteSocios != '') {
      _showAlertRegistrarSaidas(context);
      _textController.clear();
    }
  }

/*
  void _getHost(String pidUnidade) {

    String wHost = '';

    if (pidUnidade == 2) {
      wHost = '177.85.84.69';
    } else if (pidUnidade == 3) {
      wHost = '177.85.84.69';
    if (pidUnidade == 4) {
      wHost = '177.85.84.69';
    } else {      
      wHost = '177.85.84.69';
    }

    return wHost;

  }

  _getPorta(String pidUnidade) {

    String wPorta = '';
    if (pidUnidade == 2) {
      wPorta = '9099';
    } else if (pidUnidade == 3) {
      wPorta = '9099';
    if (pidUnidade == 4) {
      wPorta = '9099';
    } else {      
      wPorta = '9099';
    }
    return wPorta;

  }    
*/
  Future _showAlertRegistrarSaidas(BuildContext context) async {
    Widget concelarButton =
        FlatButton(child: Text("Cancelar"), onPressed: () => _botaoCancelar());

    Widget registrarButton = FlatButton(
        child: Text("Registrar"), onPressed: () => _registrarSaidas());
    //configura o AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Registrar Saida'),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          Text("Confirma o registro da saida de $_qteSocios sócio(s)."),
        ],
      )),
      actions: [concelarButton, registrarButton],
    );
    //exibe o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _registrarSaidas() async {
    print('Rotina - _registrarSaidas');
    print('Uniddade: $_idUnidade');
    print('portaria: $_idPortaria');
    print('dispositivo: $_idDispositivo');
    print('matricula: $_idMatricula');
    print('Saidas: $_qteSocios');

    // Registrar o socio a entrada do socio na portaria
    var dataRegEnt = await http.get(
        'http://$_host:$_porta/PostRegistraMovto/$_idUnidade/$_idPortaria/$_idDispositivo/1/999999/S/$_idMatricula/$_qteSocios');

    var jsonData = json.decode(dataRegEnt.body)['RegistraMovto'];
    int x = 0;
    _listRegistro.clear();
    for (var u in jsonData) {
      Registro documento = Registro(
        x,
        u['STATUS'],
        u['MENSAGEM'],
      );
      _listRegistro.add(documento);
      x = x + 1;
    }
    String _status = _listRegistro[0].rpStatus;
    String _mensagem = _listRegistro[0].rpMensagem;

    setState(() {
      _qrInfo = '';
      _qteSocios = '';
    });
    Navigator.pop(context);
  }

  _botaoCancelar() {
    _qrInfo = '';
    Navigator.pop(context);
  }

  _botaoRegistrar() async {
    print('PostRegistraMovto - Entrada');
    print('_host: $_host');
    print('_porta: $_porta');
    print('_idUnidade: $_idUnidade');
    print('_idPortaria: $_idPortaria');
    print('_idDispositivo: $_idDispositivo');
    print('_socioNPF: $_socioNPF');

    // Registrar o socio a entrada do socio na portaria
    var dataRegEnt = await http.get(
        'http://$_host:$_porta/PostRegistraMovto/$_idUnidade/$_idPortaria/$_idDispositivo/1/$_socioNPF/E/$_idMatricula/1');

    var jsonData = json.decode(dataRegEnt.body)['RegistraMovto'];
    int x = 0;
    _listRegistro.clear();
    for (var u in jsonData) {
      Registro documento = Registro(
        x,
        u['STATUS'],
        u['MENSAGEM'],
      );
      _listRegistro.add(documento);
      x = x + 1;
    }
    String _status = _listRegistro[0].rpStatus;
    String _mensagem = _listRegistro[0].rpMensagem;
    print('status : $_status');
    print('mensagem : $_mensagem');

    _qrInfo = '';
    Navigator.pop(context);
  }

  Future _showAlertDialog(BuildContext context) async {
    print('Base64Codec - inicio');
    // Uint8List bytes = Base64Codec().decode(_listFotoSocio[0].fotoSocio);
    var _fotoSocio = base64.decode(_listFotoSocio[0].fotoSocio);
    print('Base64Codec - fim');
    print('foto: $_fotoSocio');
    Alert(
      context: context,
      // type: AlertType.warning,
      title: "SOCIO",
      desc: "$_socioNPF - $_socioNome",
      image: Image.memory(
        _fotoSocio,
        fit: BoxFit.cover,
      ),
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

  void _onScanButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onGenerateButtonPress() {
    _qrInfo = 'Ler QR code';
    _qrInfo_old = '';
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }
}

class Registro {
  final int index;
  final String rpStatus;
  final String rpMensagem;

  Registro(this.index, this.rpStatus, this.rpMensagem);
}

class Socio {
  final int index;
  final String socioNPF;
  final String socioNome;
  final String socioCodRestriccao;
  final String socioRestricao;
  final String socioMensagem;

  Socio(this.index, this.socioNPF, this.socioNome, this.socioCodRestriccao,
      this.socioRestricao, this.socioMensagem);
}

class FotoSocio {
  final int fotoIndex;
  final String fotoCodSocio;
  final String fotoSocio;
  final String fotoMensagem;

  FotoSocio(
      this.fotoIndex, this.fotoCodSocio, this.fotoSocio, this.fotoMensagem);
}
