Calculation: Normalize(x, lookback) = 100 * (x - lowest(x, lookback)) / (highest(x, lookback) - lowest(x, lookback)); use 50 when the range is zero.
Calculation: EMA bias = EMA of 50 * indicator(close > first EMA of close AND close > second EMA of close) + 50 * indicator(first EMA > second EMA), using a smoothing length shorter than both close EMA lengths.
Calculation: Directional volume = 50 + (clamp(100 * (volume z-score + 2) / 4, 0, 100) - 50) * direction, where volume z-score is (volume - SMA(volume)) / standard deviation(volume), or zero when the standard deviation is zero, and direction is 1 when close >= open and -1 otherwise.
Calculation: Composite = EMA of the weighted average of EMA bias, MFI of typical price, Normalize(+DI - -DI), (100 - Normalize(100 * ATR / close) + EMA bias) / 2, Normalize(close - open), directional volume, and Normalize(ROC(close)); use the same smoothing length as EMA bias. Divide by 100 instead of the sum of weights when that sum is zero. The normalization lookbacks for DI spread, ATR percentage, and ROC are equal and longer than the normalization lookback for close - open.
Calculation: Higher-timeframe composite = Composite calculated on chart bars using the last completed higher-timeframe open, high, low, close, and volume, each carried forward between higher-timeframe completions. DI and ATR still use chart-timeframe high, low, and close. Use the same parameters and weights as the chart-timeframe composite.
Calculation: Displayed volatility score = (100 - Normalize(100 * chart-timeframe ATR / close) + chart-timeframe composite) / 2, using the composite's ATR normalization lookback.
Long: Chart-timeframe composite crosses above the bullish threshold AND (higher-timeframe filter is disabled OR higher-timeframe composite >= its bullish threshold).
Short: Chart-timeframe composite crosses below the bearish threshold AND (higher-timeframe filter is disabled OR higher-timeframe composite <= its bearish threshold).
Long: Chart-timeframe composite > bullish threshold AND (higher-timeframe filter is disabled OR higher-timeframe composite >= its bullish threshold).
Short: Chart-timeframe composite < bearish threshold AND (higher-timeframe filter is disabled OR higher-timeframe composite <= its bearish threshold).
Long: Chart-timeframe composite >= its bullish display threshold AND (higher-timeframe filter is disabled OR higher-timeframe composite >= its bullish threshold).
Short: Chart-timeframe composite < its bearish display threshold AND (higher-timeframe filter is disabled OR higher-timeframe composite <= its bearish threshold).
Long: Chart-timeframe composite >= EMA of chart-timeframe composite.
Short: Chart-timeframe composite < EMA of chart-timeframe composite.
Long: Chart-timeframe composite > EMA of chart-timeframe composite.
Short: Chart-timeframe composite <= EMA of chart-timeframe composite.
Long: Higher-timeframe composite >= its midpoint.
Short: Higher-timeframe composite < its midpoint.
Long: Any of chart-timeframe composite, MFI of typical price, Normalize(+DI - -DI), displayed volatility score, Normalize(close - open), directional volume, or Normalize(ROC(close)) >= its bullish table threshold.
Short: Any of chart-timeframe composite, MFI of typical price, Normalize(+DI - -DI), displayed volatility score, Normalize(close - open), directional volume, or Normalize(ROC(close)) < its bearish table threshold.