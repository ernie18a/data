Calculation: Prior completed higher-timeframe bar range = high − low; use the last completed bar of a timeframe higher than the chart timeframe.
Calculation: P = (prior higher-timeframe high + low + close) / 3
Calculation: R3 = prior higher-timeframe close + range × (1.10 / 4)
Calculation: S3 = prior higher-timeframe close − range × (1.10 / 4)
Calculation: R4 = prior higher-timeframe close + range × (1.10 / 2)
Calculation: S4 = prior higher-timeframe close − range × (1.10 / 2)
Calculation: R5 = prior higher-timeframe close + range × 1.10
Calculation: S5 = prior higher-timeframe close − range × 1.10
Long: Not the first bar of a new higher-timeframe period AND ((low ≤ S3 AND close > S3 AND close > open) OR (close > R4 AND close > open AND (prior chart-bar close ≤ R4 OR open ≤ R4)))
Short: Not the first bar of a new higher-timeframe period AND ((high ≥ R3 AND close < R3 AND close < open) OR (close < S4 AND close < open AND (prior chart-bar close ≥ S4 OR open ≥ S4)))
Exit: Long, high ≥ P OR high ≥ R3 OR low < S4 OR low ≤ R3
Exit: Short, low ≤ P OR low ≤ S3 OR high > R4 OR high ≥ S3