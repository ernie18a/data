Calculation: Weekly sampled close = close on the first chart bar of each higher-timeframe week, carried forward
Calculation: Zero-crossing oscillator = the negative EMA of (the prior-bar RSI(1) of the cumulative sum of weekly-sampled-close changes multiplied by chart-bar volume minus the prior-bar WMA of that RSI); use a longer WMA lookback and a shorter EMA lookback
Calculation: Higher-timeframe HMA3 = WMA(3 × WMA(close, p/3) − WMA(close, p/2) − WMA(close, p), p), where p is half the lookback; use the higher-timeframe value shifted back by one bar plus the configurable shift, using completed higher-timeframe bars
Long: Zero-crossing oscillator crosses above zero OR chart-timeframe linear regression of close crosses above the higher-timeframe HMA3
Exit: long, high ≥ entry price × (1 + first profit percentage) OR low ≤ entry price × (1 − stop-loss percentage)
Exit: long, high ≥ entry price × (1 + second profit percentage) OR low ≤ entry price × (1 − stop-loss percentage)
Exit: long, high ≥ entry price × (1 + third profit percentage) OR low ≤ entry price × (1 − stop-loss percentage)
Exit: long, high ≥ entry price × (1 + fourth profit percentage) OR low ≤ entry price × (1 − stop-loss percentage)