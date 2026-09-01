import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/exercicio_model.dart';
import '../models/treino_model.dart';

class EscolherExerciciosScreen extends StatefulWidget {
  final List<String> gruposSelecionados;

  const EscolherExerciciosScreen({
    super.key,
    required this.gruposSelecionados,
  });

  @override
  State<EscolherExerciciosScreen> createState() => _EscolherExerciciosScreenState();
}

class _EscolherExerciciosScreenState extends State<EscolherExerciciosScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<ExercicioModel> _exercicios = [];
  List<String> _exerciciosSelecionados = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarExercicios();
  }

  Future<void> _carregarExercicios() async {
    setState(() => _carregando = true);

    final exercicios = await _db.getExerciciosPorGrupos(
      widget.gruposSelecionados,
    );

    setState(() {
      _exercicios = exercicios;
      _carregando = false;
    });
  }

  Future<void> _finalizar() async {
    if (_exerciciosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um exercício'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nomeTreino = widget.gruposSelecionados.join(' e ');

    final treino = TreinoModel(
      nome: nomeTreino,
      gruposSelecionados: widget.gruposSelecionados.join(','),
      exercicios: _exerciciosSelecionados.join(','),
      createdAt: DateTime.now(),
    );

    try {
      await _db.salvarTreino(treino);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Treino criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Exercícios'),
        actions: [
          TextButton(
            onPressed: _exerciciosSelecionados.isEmpty ? null : _finalizar,
            child: Text(
              '✔️ Finalizar',
              style: TextStyle(
                color: _exerciciosSelecionados.isEmpty ? Colors.grey : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Grupos: ${widget.gruposSelecionados.join(", ")}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_exerciciosSelecionados.length} selecionados',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercicios.length,
                    itemBuilder: (context, index) {
                      final exercicio = _exercicios[index];
                      final isSelected = _exerciciosSelecionados.contains(exercicio.nome);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleExercicio(exercicio.nome),
                            activeColor: const Color(0xFF1A237E),
                          ),
                          title: Text(
                            exercicio.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(exercicio.grupoMuscular),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? const Color(0xFF1A237E)
                                : Colors.grey.shade300,
                          ),
                          onTap: () => _toggleExercicio(exercicio.nome),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _toggleExercicio(String nome) {
    setState(() {
      if (_exerciciosSelecionados.contains(nome)) {
        _exerciciosSelecionados.remove(nome);
      } else {
        _exerciciosSelecionados.add(nome);
      }
    });
  }
}