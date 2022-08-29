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
}
