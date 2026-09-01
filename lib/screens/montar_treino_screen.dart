import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import 'escolher_exercicios_screen.dart';

class MontarTreinoScreen extends StatefulWidget {
  const MontarTreinoScreen({super.key});

  @override
  State<MontarTreinoScreen> createState() => _MontarTreinoScreenState();
}

class _MontarTreinoScreenState extends State<MontarTreinoScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final List<String> _gruposSelecionados = [];
  List<String> _gruposDisponiveis = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
  }

  Future<void> _carregarGrupos() async {
    setState(() => _carregando = true);
    final grupos = await _db.getGruposMusculares();
    setState(() {
      _gruposDisponiveis = grupos;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Montar Treino'),
        actions: [
          TextButton(
            onPressed: _gruposSelecionados.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EscolherExerciciosScreen(
                          gruposSelecionados: _gruposSelecionados,
                        ),
                      ),
                    );
                  },
            child: Text(
              'Próximo',
              style: TextStyle(
                color: _gruposSelecionados.isEmpty ? Colors.grey : Colors.white,
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
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selecione um ou mais grupos musculares',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${_gruposSelecionados.length} selecionados',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _gruposDisponiveis.length,
                    itemBuilder: (context, index) {
                      final grupo = _gruposDisponiveis[index];
                      final isSelected = _gruposSelecionados.contains(grupo);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleGrupo(grupo),
                            activeColor: const Color(0xFF1A237E),
                          ),
                          title: Text(
                            grupo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? const Color(0xFF1A237E)
                                : Colors.grey.shade300,
                          ),
                          onTap: () => _toggleGrupo(grupo),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _toggleGrupo(String grupo) {
    setState(() {
      if (_gruposSelecionados.contains(grupo)) {
        _gruposSelecionados.remove(grupo);
      } else {
        _gruposSelecionados.add(grupo);
      }
    });
  }
}