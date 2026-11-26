Calculation: T1 MACD main = MACD main(close, shorter lookback, longer lookback, signal lookback, T1, last completed bar), sampled on chart bars
Calculation: T1 MACD signal = MACD signal(close, shorter lookback, longer lookback, signal lookback, T1, last completed bar), sampled on chart bars
Exit: long, close[1] = upper Bollinger Band(close, lookback, deviation multiplier, band shift)[1]
Exit: short, close[1] = lower Bollinger Band(close, lookback, deviation multiplier, band shift)[1]
Exit: long, T1 MACD main != 0 AND (T1 MACD main < T1 MACD signal OR open short position AND T1 MACD main > T1 MACD signal)
Exit: short, T1 MACD main != 0 AND (T1 MACD main > T1 MACD signal OR open long position AND T1 MACD main < T1 MACD signal)