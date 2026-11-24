Calculation: Spread = chart close / reference close (using 1 for a missing reference close) or chart close - reference close, according to the selected spread mode
Calculation: Source = Spread passed through EMA(Source, EMA lookback) when enabled, then through center of gravity(Source, CoG lookback) when enabled
Calculation: Normalized derivative(source, quadratic-mean lookback) = (source - source[2]) / sqrt(SMA((source - source[2])^2, quadratic-mean lookback))
Calculation: Oscillator(source, smoothing parameter, oscillator lookback, quadratic-mean lookback) = Super Smoother(tanh(Normalized derivative(source, quadratic-mean lookback)), smoothing parameter * oscillator lookback)
Calculation: Fast oscillator = Oscillator(Source, shortest smoothing parameter, oscillator lookback, quadratic-mean lookback)
Calculation: Normal oscillator = Oscillator(Source, intermediate smoothing parameter, oscillator lookback, quadratic-mean lookback)
Calculation: Slow oscillator = Oscillator(Source, longest smoothing parameter, oscillator lookback, quadratic-mean lookback)
Calculation: Fast series = fast amplitude parameter * Fast oscillator + separation parameter
Calculation: Normal series = normal amplitude parameter * Normal oscillator
Calculation: Slow series = slow amplitude parameter * Slow oscillator - separation parameter
Long: Fast oscillator >= 0 OR Normal oscillator >= 0 OR Slow oscillator >= 0
Short: Fast oscillator < 0 OR Normal oscillator < 0 OR Slow oscillator < 0
Long: Fast series crosses above Normal series AND Normal series < 0
Short: Fast series crosses below Normal series AND Normal series > 0
Long: Slow series crosses above 0 OR Normal series crosses above 0 OR Fast series crosses above 0
Short: Slow series crosses below 0 OR Normal series crosses below 0 OR Fast series crosses below 0
Long: Fast series crosses above Normal series AND Normal series < 0 AND Normal series > normal series at the previous occurrence of (Fast series crosses above Normal series AND Normal series < 0) * wave-size percentage parameter / 100 AND bars since the previous bar had such a cross < divergence-distance parameter AND Gaussian kernel estimate of the selected fast, normal, or slow series < Slow series
Short: Fast series crosses below Normal series AND Normal series > 0 AND Normal series < normal series at the previous occurrence of (Fast series crosses below Normal series AND Normal series > 0) * wave-size percentage parameter / 100 AND bars since the previous bar had such a cross < divergence-distance parameter AND Gaussian kernel estimate of the selected fast, normal, or slow series > Slow series