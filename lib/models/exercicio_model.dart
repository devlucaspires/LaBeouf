class ExercicioModel {
  final int? id;
  final String nome;
  final String grupoMuscular;

  ExercicioModel({
    this.id,
    required this.nome,
    required this.grupoMuscular,
  });

  // Converte o modelo para um Map (usado para inserir no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'grupoMuscular': grupoMuscular,
    };
  }

  // Converte um Map (vindo do banco) para o modelo
  factory ExercicioModel.fromMap(Map<String, dynamic> map) {
    return ExercicioModel(
      id: map['id'],
      nome: map['nome'],
      grupoMuscular: map['grupoMuscular'],
    );
  }
}