Calculation: Moving-average slope = SMA of (selected moving average / its value at the longer lookback − 1), using the shorter smoothing lookback; read from the higher timeframe’s last completed bar and multiplied by a scale factor. The selected average is SMA, EMA, WMA, Hull MA, VWMA, RMA, TEMA, or Tilson T3.
Calculation: Momentum slope = SMA of (selected momentum indicator / its value at the longer lookback − 1), using the shorter smoothing lookback; read from the higher timeframe’s last completed bar. The selected indicator is RSI, CCI, or RSI of ROC.
Calculation: Volatility = SMA of ((1 − low / high) × 100), using the shorter lookback.
Calculation: Low volatility = Volatility < minimum volatility threshold.
Calculation: Low-volatility up condition = (long-lookback SMA of close from three bars ago − that SMA from one bar ago) < −slope threshold.
Calculation: Low-volatility down condition = (long-lookback SMA of close from three bars ago − that SMA from one bar ago) > slope threshold.
Long: (Low volatility AND Low-volatility up condition) OR (NOT Low volatility AND Moving-average slope > buy threshold AND Momentum slope > buy threshold)
Short: (Low volatility AND Low-volatility down condition) OR (NOT Low volatility AND Moving-average slope < sell threshold AND Momentum slope < sell threshold)