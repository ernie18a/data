Calculation: Heikin Ashi balance of power = (higher-timeframe Heikin Ashi close − open) / (high − low), using the higher-timeframe bar still forming
Calculation: Smoothed balance of power = exponential moving average of Heikin Ashi balance of power
Calculation: 99th percentile = nearest-rank 99th percentile of smoothed balance of power over a lookback
Calculation: 1st percentile = nearest-rank 1st percentile of smoothed balance of power over the same lookback
Long: 99th percentile > its previous value AND (smoothed balance of power > 0 OR (smoothed balance of power > −0.35 AND its previous value < −0.35))
Short: (smoothed balance of power < 0 AND 99th percentile < its previous value AND 1st percentile < its previous value) OR (smoothed balance of power < 0.6 AND its previous value > 0.6)