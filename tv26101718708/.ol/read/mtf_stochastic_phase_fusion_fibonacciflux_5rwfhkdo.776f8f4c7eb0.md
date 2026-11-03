Calculation: Smoothed stochastic %K = simple moving average of 100 × (close − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback), calculated within each source timeframe using its last completed bar.
Calculation: Tactical wave = weighted average of the shorter-term smoothed stochastic %K readings.
Calculation: Structural wave = weighted average of the longer-term smoothed stochastic %K readings.
Calculation: Tactical coherence = 100 × the magnitude of the weighted sum of unit vectors whose real component is (smoothed %K − 50) / 50 and whose imaginary component is scaled change in smoothed %K; cap at 100. Use shorter-term readings and their weights.
Long: Tactical wave > structural wave AND previous tactical wave ≤ previous structural wave AND no long pulse is active
Short: Tactical wave < structural wave AND previous tactical wave ≥ previous structural wave AND no short pulse is active
Long: Tactical wave > 20 AND previous tactical wave ≤ 20 AND structural wave ≥ 50 AND tactical coherence ≥ threshold
Short: Tactical wave < 80 AND previous tactical wave ≥ 80 AND structural wave ≤ 50 AND tactical coherence ≥ threshold
Long: Tactical wave > 50 AND structural wave > 50 AND tactical wave change > 0 AND structural wave change ≥ 0 AND tactical coherence ≥ threshold
Short: Tactical wave < 50 AND structural wave < 50 AND tactical wave change < 0 AND structural wave change ≤ 0 AND tactical coherence ≥ threshold