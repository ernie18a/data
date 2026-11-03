Calculation: EMA structure score = +2 if fast EMA > medium EMA > slow EMA AND close > fast EMA AND close > medium EMA AND close > slow EMA; otherwise +1 if fast EMA > medium EMA > slow EMA; otherwise -2 if fast EMA < medium EMA < slow EMA AND close < fast EMA AND close < medium EMA AND close < slow EMA; otherwise -1 if fast EMA < medium EMA < slow EMA; otherwise +1 if close > slow EMA; otherwise -1 if close < slow EMA; otherwise 0.
Calculation: OBV flow score = +1 if OBV > SMA of OBV AND the SMA of OBV > its value a slope lookback ago; otherwise -1 if OBV <= SMA of OBV AND the SMA of OBV < its value a slope lookback ago; otherwise 0.
Calculation: Trend score = EMA structure score + 1 when Supertrend is bullish or -1 when Supertrend is bearish + OBV flow score.
Calculation: Multi-timeframe readings = trend score, EMA structure score, close versus slow EMA, Supertrend direction, and OBV versus its SMA and SMA slope, calculated independently on each of the configured timeframes. For a higher timeframe, use the last completed bar on historical bars and the still-forming bar in real time; for a lower timeframe, use the last available intrabar within the chart bar.
Long: Fast EMA > medium EMA AND medium EMA > slow EMA.
Short: Fast EMA < medium EMA AND medium EMA < slow EMA.
Long: Medium EMA crosses above slow EMA.
Short: Medium EMA crosses below slow EMA.
Long: Supertrend changes from bearish to bullish.
Short: Supertrend changes from bullish to bearish.
Long: On any configured timeframe, EMA structure score > 0 OR close > slow EMA OR Supertrend is bullish OR OBV > SMA of OBV OR SMA of OBV > its value a slope lookback ago OR trend score > 0.
Short: On any configured timeframe, EMA structure score < 0 OR close <= slow EMA OR Supertrend is bearish OR (OBV <= SMA of OBV AND SMA of OBV <= its value a slope lookback ago) OR trend score < 0.
Long: The number of configured timeframes with trend score > 0 is greater than the number with trend score < 0.
Short: The number of configured timeframes with trend score < 0 is greater than the number with trend score > 0.
Long: Chart-timeframe trend score reaches the strong bullish classification from a different classification.
Short: Chart-timeframe trend score reaches the strong bearish classification from a different classification.
Calculation: Strong bullish classification = trend score >= 3; strong bearish classification = trend score <= -3.