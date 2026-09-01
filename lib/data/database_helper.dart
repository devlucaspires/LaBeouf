import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/exercicio_model.dart';
import '../models/treino_model.dart';
import 'exercicios_data.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'labeouf.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de exercícios
    await db.execute('''
      CREATE TABLE exercicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        grupoMuscular TEXT NOT NULL
      )
    ''');

    // Tabela de treinos
    await db.execute('''
      CREATE TABLE treinos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        gruposSelecionados TEXT NOT NULL,
        exercicios TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Inserir exercícios iniciais
    for (var exercicio in ExerciciosData.exercicios) {
      await db.insert(
        'exercicios',
        {
          'nome': exercicio['nome'],
          'grupoMuscular': exercicio['grupoMuscular'],
        },
      );
    }
  }

  // ============================================================
  // EXERCÍCIOS
  // ============================================================

  Future<List<ExercicioModel>> getExercicios() async {
    final db = await database;
    final result = await db.query('exercicios', orderBy: 'nome');
    return result.map((map) => ExercicioModel.fromMap(map)).toList();
  }

  Future<List<ExercicioModel>> getExerciciosPorGrupos(List<String> grupos) async {
    final db = await database;
    final placeholders = grupos.map((_) => '?').join(',');
    final result = await db.query(
      'exercicios',
      where: 'grupoMuscular IN ($placeholders)',
      whereArgs: grupos,
      orderBy: 'nome',
    );
    return result.map((map) => ExercicioModel.fromMap(map)).toList();
  }

  Future<List<String>> getGruposMusculares() async {
    final db = await database;
    final result = await db.query('exercicios');
    final grupos = result
        .map((map) => map['grupoMuscular'] as String)
        .toSet()
        .toList()
      ..sort();
    return grupos;
  }

  // ============================================================
  // TREINOS
  // ============================================================

  Future<List<TreinoModel>> getTreinos() async {
    final db = await database;
    final result = await db.query(
      'treinos',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => TreinoModel.fromMap(map)).toList();
  }

  Future<int> salvarTreino(TreinoModel treino) async {
    final db = await database;
    return await db.insert(
      'treinos',
      treino.toMap(),
    );
  }

  Future<int> deletarTreino(int id) async {
    final db = await database;
    return await db.delete(
      'treinos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}