import 'package:flutter/material.dart';
import 'package:equalizer_flutter/equalizer_flutter.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  bool _isEqualizerAvailable = false;
  List<int>? _bandLevels;
  int _centerBandIdx = 0;
  int _minBandLevel = 0;
  int _maxBandLevel = 0;

  @override
  void initState() {
    super.initState();
    _initEqualizer();
  }

  Future<void> _initEqualizer() async {
    try {
      // Init equalizer
      await EqualizerFlutter.init(0);
      
      // Get available status
      final available = await EqualizerFlutter.isAvailable;
      
      if (available) {
        // Get band levels
        final minLevel = await EqualizerFlutter.getMinBandLevel;
        final maxLevel = await EqualizerFlutter.getMaxBandLevel;
        final centerIdx = await EqualizerFlutter.getCenterBandLevel;
        final numBands = await EqualizerFlutter.getNumberOfBands;
        
        // Get current levels for all bands
        List<int> levels = [];
        for (int i = 0; i < numBands; i++) {
          final level = await EqualizerFlutter.getBandLevel(i);
          levels.add(level);
        }
        
        setState(() {
          _isEqualizerAvailable = true;
          _minBandLevel = minLevel;
          _maxBandLevel = maxLevel;
          _centerBandIdx = centerIdx;
          _bandLevels = levels;
        });
      } else {
        setState(() {
          _isEqualizerAvailable = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing equalizer: $e');
      setState(() {
        _isEqualizerAvailable = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menginisialisasi equalizer'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _setBandLevel(int bandId, int level) async {
    try {
      await EqualizerFlutter.setBandLevel(bandId, level);
      setState(() {
        if (_bandLevels != null && bandId < _bandLevels!.length) {
          _bandLevels![bandId] = level;
        }
      });
    } catch (e) {
      debugPrint('Error setting band level: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengatur level band'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _setPreset(String presetName) async {
    try {
      await EqualizerFlutter.setPreset(presetName);
      // Refresh band levels
      _initEqualizer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preset "$presetName" diterapkan'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error setting preset: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menerapkan preset'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
      ),
      body: _isEqualizerAvailable
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Presets
                    Text(
                      'Preset',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('Normal'),
                        _buildPresetChip('Rock'),
                        _buildPresetChip('Pop'),
                        _buildPresetChip('Jazz'),
                        _buildPresetChip('Classical'),
                        _buildPresetChip('Bass Boost'),
                        _buildPresetChip('Treble Boost'),
                        _buildPresetChip('Vocal Booster'),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Custom equalizer
                    Text(
                      'Custom',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_bandLevels != null)
                      SizedBox(
                        height: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            _bandLevels!.length,
                            (index) => _buildBandSlider(index),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.equalizer,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Equalizer tidak tersedia',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fitur ini hanya tersedia di Android',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPresetChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _setPreset(label),
    );
  }

  Widget _buildBandSlider(int bandId) {
    if (_bandLevels == null || bandId >= _bandLevels!.length) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: Slider(
                value: _bandLevels![bandId].toDouble(),
                min: _minBandLevel.toDouble(),
                max: _maxBandLevel.toDouble(),
                onChanged: (value) {
                  _setBandLevel(bandId, value.toInt());
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${bandId + 1}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Only release if equalizer was successfully initialized
    if (_isEqualizerAvailable) {
      EqualizerFlutter.release();
    }
    super.dispose();
  }
}
