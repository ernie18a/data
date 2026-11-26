Calculation: Bullish vote count = sum of 1 for each true condition among close > VWAP(hlc3), EMA(close, shorter lookback) > EMA(close, longer lookback), and RSI(close, lookback) > 50
Calculation: Bearish vote count = sum of 1 for each true condition among close <= VWAP(hlc3), EMA(close, shorter lookback) <= EMA(close, longer lookback), and RSI(close, lookback) <= 50
Long: Bullish vote count >= 2
Short: Bearish vote count >= 2
Long: ADX(high, low, close, lookback, same lookback) >= threshold AND Bullish vote count >= 2
Short: ADX(high, low, close, lookback, same lookback) >= threshold AND Bearish vote count >= 2
Long: Engulfing signals enabled AND close > open AND close[1] < open[1] AND close > open[1] AND open < close[1] AND (ADX filter disabled OR ADX(high, low, close, lookback, same lookback) >= threshold) AND (RSI filter disabled OR (RSI(close, lookback) > 30 AND RSI(close, lookback) < 70)) AND (EMA trend filter disabled OR EMA(close, shorter lookback) > EMA(close, longer lookback))
Short: Engulfing signals enabled AND close < open AND close[1] > open[1] AND close < open[1] AND open > close[1] AND (ADX filter disabled OR ADX(high, low, close, lookback, same lookback) >= threshold) AND (RSI filter disabled OR (RSI(close, lookback) > 30 AND RSI(close, lookback) < 70)) AND (EMA trend filter disabled OR EMA(close, shorter lookback) <= EMA(close, longer lookback))
Long: crossover(close, VWAP(hlc3))
Short: crossunder(close, VWAP(hlc3))
Long: crossover(EMA(close, shorter lookback), EMA(close, longer lookback))
Short: crossunder(EMA(close, shorter lookback), EMA(close, longer lookback))