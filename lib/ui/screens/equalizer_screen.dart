import 'package:flutter/material.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  // Preset configurations for different music styles
  final Map<String, List<double>> _presets = {
    'Normal': [0.0, 0.0, 0.0, 0.0, 0.0],
    'Rock': [0.6, 0.4, -0.2, 0.3, 0.7],
    'Pop': [0.3, 0.5, 0.2, -0.1, 0.4],
    'Jazz': [0.4, 0.2, 0.1, 0.2, 0.5],
    'Bass Boost': [0.8, 0.6, 0.0, -0.2, -0.1],
    'Classical': [0.5, 0.3, 0.2, 0.4, 0.6],
    'Hip Hop': [0.7, 0.5, 0.0, 0.2, 0.6],
    'Electronic': [0.5, 0.3, 0.0, 0.4, 0.7],
  };

  final List<String> _frequencies = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];
  
  String _selectedPreset = 'Normal';
  List<double> _bandLevels = [0.0, 0.0, 0.0, 0.0, 0.0];

  void _applyPreset(String presetName) {
    setState(() {
      _selectedPreset = presetName;
      _bandLevels = List.from(_presets[presetName]!);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset "$presetName" diterapkan'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateBandLevel(int index, double value) {
    setState(() {
      _bandLevels[index] = value;
      _selectedPreset = 'Custom';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Equalizer UI mockup - Pilih preset atau sesuaikan band frekuensi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Presets Section
              Text(
                'Preset',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.keys.map((preset) {
                  final isSelected = _selectedPreset == preset;
                  return ChoiceChip(
                    label: Text(preset),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _applyPreset(preset);
                    },
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surface,
                    labelStyle: TextStyle(
                      color: isSelected 
                          ? colorScheme.onPrimaryContainer 
                          : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Frequency Bands Section
              Text(
                'Frequency Bands',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current: $_selectedPreset',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Equalizer Bands
              SizedBox(
                height: 320,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    _frequencies.length,
                    (index) => _buildBandSlider(
                      index,
                      _frequencies[index],
                      colorScheme,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Reset Button
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: () => _applyPreset('Normal'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset ke Normal'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBandSlider(int index, String frequency, ColorScheme colorScheme) {
    final value = _bandLevels[index];
    final normalizedValue = ((value + 1.0) / 2.0) * 100; // Normalize from range -1.0 to 1.0 into 0 to 100 for slider display
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Slider
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.surfaceContainerHighest,
                  thumbColor: colorScheme.primary,
                  overlayColor: colorScheme.primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: normalizedValue,
                  min: 0,
                  max: 100,
                  onChanged: (newValue) {
                    // Convert back from 0-100 to -1.0 to 1.0
                    final actualValue = (newValue / 100 * 2.0) - 1.0;
                    _updateBandLevel(index, actualValue);
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Frequency Label
          Text(
            frequency,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
