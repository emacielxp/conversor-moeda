import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const requestURL = "https://api.hgbrasil.com/finance?format=json&key=68dccaca";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
      )
    )
  ));
}

Future<Map> recuperaDadosCotacoes() async {
  http.Response response = await http.get(requestURL);
  return json.decode(response.body)["results"]["currencies"];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controleReal = TextEditingController();
  final controleDolar = TextEditingController();
  final controleEuro = TextEditingController();

  double dolar;
  double euro;

  void _limpaCampos(){
    controleReal.text = "";
    controleDolar.text = "";
    controleEuro.text = "";
  }

  void _alteraReal(String texto) {
    if(texto.isEmpty) {
      _limpaCampos();
      return;
    }
    double real = double.parse(texto);
    controleDolar.text = (real / dolar).toStringAsFixed(2);
    controleEuro.text = (real / euro).toStringAsFixed(2);
  }

  void _alteraDolar(String texto) {
    if(texto.isEmpty) {
      _limpaCampos();
      return;
    }
    double dolar = double.parse(texto);
    controleReal.text = (dolar * this.dolar).toStringAsFixed(2);
    controleEuro.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _alteraEuro(String texto) {
    if(texto.isEmpty) {
      _limpaCampos();
      return;
    }
    double euro = double.parse(texto);
    controleReal.text = (euro * this.euro).toStringAsFixed(2);
    controleDolar.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$\$ Conversor \$\$"),
        backgroundColor: Colors.amber,
        centerTitle: true
      ),
      body: FutureBuilder<Map>(
        future: recuperaDadosCotacoes(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text("Carregando...",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0
                      ),
                      textAlign: TextAlign.center
                  )
              );
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text("Erro ao carregar os dados!",
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 25.0
                        ),
                        textAlign: TextAlign.center
                    )
                );
              } else {
                dolar = snapshot.data["USD"]["buy"];
                euro = snapshot.data["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber
                      ),
                      criaTextField("Reais", "R\$", controleReal, _alteraReal),
                      Divider(),
                      criaTextField("Dolares", "US\$", controleDolar, _alteraDolar),
                      Divider(),
                      criaTextField("Euros", "£", controleEuro, _alteraEuro),
                    ],
                  )
                );
              }
          }
        })
    );
  }
}

Widget criaTextField(String label, String prefixo, TextEditingController controlador, Function funcao) {
  return TextField(
    controller: controlador,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefixo
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: funcao,
  );
}