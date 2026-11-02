Calculation: Source = a selectable price derived from the bar's open, high, low and close.
Calculation: Anchor window = a selectable rolling window, or the window from the latest confirmed swing low, swing high, or most recent of either. A swing is confirmed after an equal pivot lookback on each side; include bars from the pivot through the current bar. If the selected swing has not formed, use the rolling window.
Calculation: Anchored VWAP = sum(source × volume) / sum(volume) over the anchor window.
Calculation: Anchored sigma = sqrt(max(sum(source² × volume) / sum(volume) − anchored VWAP², 0)) over the anchor window.
Calculation: Decayed VWAP = decayed sum(source × volume) / decayed sum(volume), with each prior sum multiplied by a per-bar half-life decay factor before adding the current bar. Initialize from the current bar and reset on confirmation of the selected swing type, or either swing in dual mode; do not reset in rolling mode.
Calculation: Efficiency ratio = absolute change in close over a lookback / sum of absolute bar-to-bar close changes over that lookback; use zero if the denominator is zero.
Calculation: Higher-timeframe rolling VWAP = rolling VWAP calculated separately on each of three higher timeframes of increasing length, using the higher-timeframe bar still forming.
Long: Decayed VWAP crosses above anchored VWAP AND (regime filter disabled OR (efficiency ratio > its threshold AND ADX > its threshold)).
Short: Decayed VWAP crosses below anchored VWAP AND (regime filter disabled OR (efficiency ratio > its threshold AND ADX > its threshold)).
Long: Rolling VWAP crosses above anchored VWAP.
Short: Rolling VWAP crosses below anchored VWAP.
Long: Source ≤ anchored VWAP − stretch threshold × anchored sigma AND anchored sigma > 0.
Short: Source ≥ anchored VWAP + stretch threshold × anchored sigma AND anchored sigma > 0.
Long: Decayed VWAP ≥ anchored VWAP.
Short: Decayed VWAP ≤ anchored VWAP.
Long: Close ≥ higher-timeframe rolling VWAP for any of the three higher timeframes.
Short: Close < higher-timeframe rolling VWAP for any of the three higher timeframes.