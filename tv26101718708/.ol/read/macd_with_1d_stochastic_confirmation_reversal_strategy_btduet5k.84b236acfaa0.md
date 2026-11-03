Calculation: MACD line = short-term EMA(close) − long-term EMA(close)
Calculation: MACD signal line = EMA(MACD line)
Calculation: Daily Stochastic %K = (daily close − lowest daily low over the lookback) ÷ (highest daily high − lowest daily low over the lookback) × 100; %D = SMA(%K) over a shorter lookback. Use the higher-timeframe daily bar still forming in real time; historical values use completed daily bars.
Long: MACD line crosses above MACD signal line AND daily %K > daily %D AND daily %K < 80 AND datetime is within the configured trading period
Exit: long, low <= entry price − ATR × stop parameter OR (trailing has activated after high crosses above entry price + ATR × activation parameter AND close < chart-timeframe EMA)