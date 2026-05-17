import 'package:flutter/material.dart';
import '../../application/ports/settings_port.dart';
import '../../infrastructure/services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  final int currentColor;
  final ValueChanged<int> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.currentColor,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tema de la App',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Selecciona un color para el tema:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeSelector(),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themes = SettingsPort.availableThemes;
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: themes.map((themeName) {
        final colorValue = SettingsPort.getColorByName(themeName);
        final isSelected = widget.currentColor == colorValue;
        
        return GestureDetector(
          onTap: () async {
            await _settingsService.setThemeColor(colorValue);
            widget.onThemeChanged(colorValue);
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(colorValue).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}