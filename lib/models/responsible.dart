class Responsible {
  final String nome;
  final int? id;
  final DateTime dataNascimento;

  Responsible({
    this.id,
    required this.nome,
    required this.dataNascimento
  });

  factory Responsible.fromJson(Map<String, dynamic> json) => Responsible(
      id: json['id'],
      dataNascimento: DateTime.parse(json['data_nascimento']),
      nome: json['nome'],
  );

  Map<String, dynamic> toJson(){

    Map<String, dynamic> responsibleJson = {
      'nome': nome,
      'data_nascimento': dataNascimento.toIso8601String()
    };
    return responsibleJson;
  }
}

