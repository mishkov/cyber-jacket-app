class VisualizerConfiguration {
  final double amplitudeThreshold;
  final double amplitudeLimit;

  VisualizerConfiguration({
    required this.amplitudeThreshold,
    required this.amplitudeLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'amplitudeThreshold': amplitudeThreshold,
      'amplitudeLimit': amplitudeLimit,
    };
  }

  factory VisualizerConfiguration.fromMap(Map<String, dynamic> map) {
    return VisualizerConfiguration(
      amplitudeThreshold: map['amplitudeThreshold'] ?? 0.0,
      amplitudeLimit: map['amplitudeLimit'] ?? 0.0,
    );
  }
}
