class Unidade {
  String unidadeCodigo;
  String unidadeDescricao;

  Unidade(String unidadeCodigo, String unidadeDescricao) {
    this.unidadeCodigo = unidadeCodigo;
    this.unidadeDescricao = unidadeDescricao;
  }

  Unidade.fromJson(Map json)
      : unidadeCodigo = json['COD_UNIDADE'],
        unidadeDescricao = json['DES_UNIDADE'];

  Map toJson() {
    return {'COD_UNIDADE': unidadeCodigo, 'DES_UNIDADE': unidadeDescricao};
  }
}
