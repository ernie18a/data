Calculation: Hero score = configurable weighted sum of: close above VWAP; volume above its longer-lookback average times a configurable expansion multiplier; close above the previous-day high or below the previous-day low; close above the opening-range high or below its low; and ATR above its longer-lookback average.
Calculation: Previous-day high and low = high and low of the last completed daily bar, on a timeframe higher than the chart timeframe.
Calculation: Opening-range high and low = highest high and lowest low of chart-timeframe bars in the configured opening session, including the bar still forming.
Long: Hero score >= configured high-score threshold AND close > EMA AND close > VWAP
Short: Hero score >= configured high-score threshold AND close < EMA AND close < VWAP