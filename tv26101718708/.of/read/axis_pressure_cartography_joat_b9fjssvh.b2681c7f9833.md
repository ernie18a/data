Calculation: Pressure signal = EMA of normalized pressure, where normalized pressure = (close − moving average of close) / maximum absolute deviation from that moving average over the normalization lookback × 100
Calculation: Pressure slope = current pressure signal − previous pressure signal
Calculation: Pressure median = moving average of the pressure signal over a lookback longer than its smoothing lookback
Calculation: Active pressure state = most recently confirmed candidate state, held until a different candidate persists for the configured confirmation window; candidate is overheated positive when pressure signal ≥ upper extreme, overheated negative when ≤ lower extreme, positive expansion when pressure slope > 0 and signal > upper warning, negative expansion when slope < 0 and signal < lower warning, compression when absolute slope < threshold and absolute signal < warning level × factor, otherwise constructive positive when signal > 0 or constructive negative when signal < 0, else balanced
Long: pressure signal > 0 AND previous pressure signal ≤ 0
Long: pressure signal > upper warning AND pressure > pressure signal
Long: active pressure state > 0 AND pressure signal ≥ pressure median
Long: active pressure state > previous active pressure state
Long: pressure was ≥ upper extreme on the previous bar AND current pressure < upper extreme
Long: active pressure state = overheated negative AND pressure signal > lower warning
Short: pressure signal < 0 AND previous pressure signal ≥ 0
Short: pressure signal < lower warning AND pressure < pressure signal
Short: active pressure state < 0 AND pressure signal ≤ pressure median
Short: active pressure state < previous active pressure state
Short: pressure was ≤ lower extreme on the previous bar AND current pressure > lower extreme
Short: active pressure state = overheated positive AND pressure signal < upper warning