Calculation: Upper Keltner band = EMA of close over the configured lookback + configured multiplier × ATR over its configured lookback
Calculation: Lower Keltner band = EMA of close over the configured lookback − configured multiplier × ATR over its configured lookback
Calculation: Alligator lines = smoothed moving averages of hl2, with jaw using the longest lookback and greatest backward offset, teeth intermediate, and lips the shortest lookback and least backward offset
Calculation: Bullish vote count = count of conditions true: close > upper Keltner band; lips > teeth > jaw; close > VWAP; RSI > 50 and < its overbought threshold; MACD line > signal line and > 0
Calculation: Bearish vote count = count of conditions true: close < lower Keltner band; lips < teeth < jaw; close < VWAP; RSI < 50 and > its oversold threshold; MACD line < signal line and < 0
Long: bullish vote count >= configured vote threshold AND bullish vote count > bearish vote count AND previous emitted signal is not long
Short: bearish vote count >= configured vote threshold AND bearish vote count > bullish vote count AND previous emitted signal is not short