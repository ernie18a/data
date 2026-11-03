Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Prior daily high, low, and close = high, low, and close of the last completed daily bar on a higher timeframe than the chart timeframe
Calculation: Pivot = (prior daily high + prior daily low + prior daily close) / 3
Calculation: First resistance = 2 × pivot − prior daily low
Calculation: First support = 2 × pivot − prior daily high
Long: close > VWAP AND close > EMA AND close > open AND high − max(close, open) < abs(close − open) × body-fraction threshold AND volume > average volume × volume-multiplier threshold AND prior daily high − close > distance threshold AND first resistance − close > distance threshold AND close > prior chart-timeframe bar high
Short: close < VWAP AND close < EMA AND close < open AND min(close, open) − low < abs(close − open) × body-fraction threshold AND volume > average volume × volume-multiplier threshold AND close − prior daily low > distance threshold AND close − first support > distance threshold AND close < prior chart-timeframe bar low