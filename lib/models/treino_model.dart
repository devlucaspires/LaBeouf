class TreinoModel {
  final int? id;
  final String nome;
  final String gruposSelecionados; // Ex: "Peito,Tríceps"
  final String exercicios;         // Ex: "Supino Reto,Crucifixo,Tríceps Testa"
  final DateTime createdAt;

  TreinoModel({
    this.id,
    required this.nome,
    required this.gruposSelecionados,
    required this.exercicios,
    required this.createdAt,
  });

  // Converte o modelo para um Map (usado para inserir no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'gruposSelecionados': gruposSelecionados,
      'exercicios': exercicios,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Converte um Map (vindo do banco) para o modelo
  factory TreinoModel.fromMap(Map<String, dynamic> map) {
    return TreinoModel(
      id: map['id'],
      nome: map['nome'],
      gruposSelecionados: map['gruposSelecionados'],
      exercicios: map['exercicios'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Getters para converter strings em listas (facilitam o uso)
  List<String> get listaGrupos => gruposSelecionados.split(',');
  List<String> get listaExercicios => exercicios.split(',');
}