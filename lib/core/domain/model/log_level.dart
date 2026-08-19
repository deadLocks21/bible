/// Sévérité d'un enregistrement de log.
///
/// Calquée sur l'échelle `SeverityNumber` d'OpenTelemetry, pour qu'un
/// adaptateur d'export n'ait pas à réinventer sa traduction le jour où
/// l'application enverra ses logs ailleurs que dans la console.
enum LogLevel {
  debug(5, 'DEBUG'),
  info(9, 'INFO'),
  warn(13, 'WARN'),
  error(17, 'ERROR');

  const LogLevel(this.otelSeverityNumber, this.otelSeverityText);

  /// Sévérité numérique OpenTelemetry.
  final int otelSeverityNumber;

  /// Sévérité textuelle OpenTelemetry, affichable telle quelle.
  final String otelSeverityText;
}
