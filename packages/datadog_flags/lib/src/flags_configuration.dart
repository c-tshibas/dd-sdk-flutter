// Unless explicitly stated otherwise all files in this repository are licensed
// under the Apache License Version 2.0. This product includes software
// developed at Datadog (https://www.datadoghq.com/).
// Copyright 2019-Present Datadog, Inc.

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'datadog_flags_config.dart';
import 'flags_store.dart';

/// Runtime configuration for Datadog feature flag clients.
@immutable
final class DatadogFlagsConfiguration {
  /// Default interval for aggregating and sending flag evaluation telemetry.
  static const defaultEvaluationFlushInterval = Duration(seconds: 10);

  /// Smallest supported flag evaluation telemetry flush interval.
  static const minEvaluationFlushInterval = Duration(seconds: 1);

  /// Largest supported flag evaluation telemetry flush interval.
  static const maxEvaluationFlushInterval = Duration(seconds: 60);

  /// Default timeout for each precomputed assignment request.
  static const defaultAssignmentRequestTimeout = Duration(seconds: 1);

  /// Default number of retries after the first assignment request attempt.
  static const defaultAssignmentRequestRetryCount = 1;

  /// Overrides the precompute assignments endpoint.
  final Uri? customFlagsEndpoint;

  /// Additional headers sent with precompute assignment requests.
  final Map<String, String>? customFlagsHeaders;

  /// Timeout for each precomputed assignment request.
  ///
  /// Values less than or equal to zero use [defaultAssignmentRequestTimeout].
  final Duration assignmentRequestTimeout;

  /// Number of retries after a transient assignment request failure.
  ///
  /// Negative values are treated as zero.
  final int assignmentRequestRetryCount;

  /// Overrides the exposure intake endpoint.
  final Uri? customExposureEndpoint;

  /// Whether successful evaluations should emit exposure telemetry.
  final bool trackExposures;

  /// Overrides the flag evaluation intake endpoint.
  final Uri? customEvaluationEndpoint;

  /// Whether evaluations should be aggregated and sent to intake.
  final bool trackEvaluations;

  final Duration _evaluationFlushInterval;

  /// HTTP client used for assignments and telemetry.
  ///
  /// When omitted, [DatadogFlags] creates and owns a default client.
  final http.Client? httpClient;

  /// Datadog organization, environment, and site configuration.
  final DatadogFlagsConfig? datadogConfig;

  /// Optional assignment store used to seed startup from the last known data.
  final DatadogFlagsStore? store;

  /// Clock used for timestamps in stored assignments and telemetry.
  final DateTime Function() dateProvider;

  /// Creates SDK runtime configuration.
  const DatadogFlagsConfiguration({
    this.customFlagsEndpoint,
    this.customFlagsHeaders,
    this.assignmentRequestTimeout = defaultAssignmentRequestTimeout,
    this.assignmentRequestRetryCount = defaultAssignmentRequestRetryCount,
    this.customExposureEndpoint,
    this.trackExposures = true,
    this.customEvaluationEndpoint,
    this.trackEvaluations = true,
    Duration evaluationFlushInterval = defaultEvaluationFlushInterval,
    this.httpClient,
    this.datadogConfig,
    this.store,
    this.dateProvider = DateTime.now,
  }) : _evaluationFlushInterval = evaluationFlushInterval;

  /// Flush interval coerced to the same 1s-60s bounds used by the iOS and
  /// Android Flags SDKs.
  Duration get evaluationFlushInterval {
    if (_evaluationFlushInterval < minEvaluationFlushInterval) {
      return minEvaluationFlushInterval;
    }
    if (_evaluationFlushInterval > maxEvaluationFlushInterval) {
      return maxEvaluationFlushInterval;
    }
    return _evaluationFlushInterval;
  }
}
