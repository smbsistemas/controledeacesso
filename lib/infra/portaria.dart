class Portaria {
  String portariaCodigo;
  String portariaDescricao;

  Portaria(String unidadeCodigo, String portariaDescricao) {
    this.portariaCodigo = portariaCodigo;
    this.portariaDescricao = portariaDescricao;
  }

  Portaria.fromJson(Map json)
      : portariaCodigo = json['COD_PORTARIA'],
        portariaDescricao = json['DES_PORTARIA'];

  Map toJson() {
    return {'COD_UNIDADE': portariaCodigo, 'DES_UNIDADE': portariaDescricao};
  }
}
