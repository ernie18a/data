Calculation: Bullish baseline state = previous close > previous Hull moving average of close + previous ATR × buffer multiplier.
Calculation: Bearish baseline state = previous close < previous Hull moving average of close − previous ATR × buffer multiplier.
Calculation: Bullish directional state = previous ADX > trend threshold AND previous positive directional indicator > previous negative directional indicator.
Calculation: Bearish directional state = previous ADX > trend threshold AND previous negative directional indicator > previous positive directional indicator.
Calculation: Bullish momentum state = previous CCI of close > positive threshold.
Calculation: Bearish momentum state = previous CCI of close < negative threshold of equal magnitude.
Calculation: Volume state = previous volume > previous Wilder moving average of volume × volume multiplier.
Calculation: Hurst estimate = for the previous completed window of closes, calculate its mean and population standard deviation; accumulate each close minus that mean from newest to oldest, including zero when finding the minimum and maximum cumulative sums. Divide their range by the standard deviation if the standard deviation > a small positive tolerance, otherwise use zero. The estimate is log of that ratio divided by log of the window length; use zero for the numerator if the ratio is at most the tolerance.
Calculation: Momentum inflation ratio = (absolute change in previous close / previous ATR) / (previous Wilder moving average of absolute close changes / previous Wilder moving average of ATR). Use zero for either normalized speed if its ATR denominator is at most a small positive tolerance; use one for the ratio if the historical normalized speed is at most that tolerance.
Calculation: Directional confluence = the corresponding baseline state AND directional state AND momentum state AND volume state AND, if enabled, Hurst estimate > trending threshold AND, if enabled, momentum inflation ratio <= inflation threshold AND, if decay is enabled, three × max(0, 1 − consecutive bars including the current bar with all four corresponding states true / decay window) >= minimum score. The cross-asset correlation filter must be disabled because its data is unavailable.
Calculation: Baseline distance integral = rolling sum of previous close minus previous Hull moving average of close.
Long: Bullish baseline state = true.
Short: Bearish baseline state = true.
Long: Bullish directional state = true.
Short: Bearish directional state = true.
Long: Bullish momentum state = true.
Short: Bearish momentum state = true.
Long: Baseline distance integral > 0.
Short: Baseline distance integral <= 0.
Long: Bullish directional confluence = true AND previous bar's bullish directional confluence = false AND bars since the most recent long or short confluence signal, counted before updating on the current bar, >= minimum signal gap.
Short: Bearish directional confluence = true AND previous bar's bearish directional confluence = false AND bars since the most recent long or short confluence signal, counted before updating on the current bar, >= minimum signal gap.
Exit: long, previous CCI of close using the shorter exit lookback < 0 AND CCI of close two bars ago using the same lookback >= 0.
Exit: short, previous CCI of close using the shorter exit lookback > 0 AND CCI of close two bars ago using the same lookback <= 0.