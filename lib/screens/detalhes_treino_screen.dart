import 'package:flutter/material.dart';
import '../models/treino_model.dart';
import '../data/database_helper.dart';

class DetalhesTreinoScreen extends StatefulWidget {
  final TreinoModel treino;

  const DetalhesTreinoScreen({super.key, required this.treino});

  @override
  State<DetalhesTreinoScreen> createState() => _DetalhesTreinoScreenState();
}

class _DetalhesTreinoScreenState extends State<DetalhesTreinoScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  // Estado dos exercícios: cada exercício tem um booleano (feito ou não)
  late List<bool> _exerciciosFeitos;

  // Estado das repetições: 5 halteres na barra inferior
  late List<bool> _repeticoesFeitas;

  @override
  void initState() {
    super.initState();
    // Inicializa todos os exercícios como "não feitos"
    _exerciciosFeitos = List.filled(widget.treino.listaExercicios.length, false);
    // Inicializa as 5 repetições como "não feitas"
    _repeticoesFeitas = List.filled(5, false);
  }

  // Conta quantas repetições foram feitas
  int get _repeticoesConcluidas =>
      _repeticoesFeitas.where((feito) => feito).length;

  // Alterna o estado de um exercício (feito/não feito)
  void _toggleExercicio(int index) {
    setState(() {
      _exerciciosFeitos[index] = !_exerciciosFeitos[index];
    });
  }

  // Alterna o estado de uma repetição (feita/não feita)
  void _toggleRepeticao(int index) {
    setState(() {
      _repeticoesFeitas[index] = !_repeticoesFeitas[index];
    });
  }

  // Confirmação e exclusão do treino
  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Treino'),
          content: const Text(
            'Tem certeza que deseja excluir este treino?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _db.deletarTreino(widget.treino.id!);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // Volta para a lista de treinos
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciciosLista = widget.treino.listaExercicios;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treino.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _confirmarExclusao(context),
            tooltip: 'Excluir treino',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info dos grupos
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.category,
                    size: 20,
                    color: Color(0xFF1A237E),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Grupos: ${widget.treino.listaGrupos.join(", ")}',
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
                      '${exerciciosLista.length} exercícios',
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
            const SizedBox(height: 24),

            // Lista de exercícios com halteres
            const Text(
              'Exercícios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: exerciciosLista.length,
                itemBuilder: (context, index) {
                  final exercicio = exerciciosLista[index];
                  final isFeito = _exerciciosFeitos[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isFeito ? const Color(0xFF1A237E) : Colors.grey.shade300,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isFeito ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        exercicio,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: isFeito ? TextDecoration.lineThrough : null,
                          color: isFeito ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.fitness_center,
                          color: isFeito ? const Color(0xFF1A237E) : Colors.grey.shade400,
                          size: 28,
                        ),
                        onPressed: () => _toggleExercicio(index),
                        tooltip: isFeito ? 'Desmarcar' : 'Marcar como feito',
                      ),
                    ),
                  );
                },
              ),
            ),

            // Barra inferior com 5 halteres (repetições)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Repetições',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      Text(
                        '$_repeticoesConcluidas de 5',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _repeticoesConcluidas == 5
                              ? Colors.green
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 5 halteres
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final isFeito = _repeticoesFeitas[index];
                      return GestureDetector(
                        onTap: () => _toggleRepeticao(index),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFeito
                                ? const Color(0xFF1A237E)
                                : Colors.grey.shade200,
                            border: Border.all(
                              color: isFeito
                                  ? const Color(0xFF1A237E)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: isFeito ? Colors.white : Colors.grey.shade500,
                            size: 24,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Texto de conclusão
                  if (_repeticoesConcluidas == 5)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✅ Treino concluído!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}