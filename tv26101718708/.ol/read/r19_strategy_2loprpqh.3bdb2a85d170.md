Calculation: MACD line = short-period EMA of the higher-timeframe close minus long-period EMA of the higher-timeframe close; use the last completed higher-timeframe bar.
Calculation: MACD signal line = EMA of the MACD line with a shorter smoothing lookback than the MACD lookbacks; use the last completed higher-timeframe bar.
Calculation: Long MACD threshold = 0.729 × the lowest MACD line value over its lookback; use the last completed higher-timeframe bars.
Calculation: Short MACD threshold = 0.729 × the highest MACD line value over its lookback; use the last completed higher-timeframe bars.
Calculation: ADX = standard ADX computed from the higher-timeframe highs and lows; use the last completed higher-timeframe bars.
Calculation: RSI = 50-period RSI of the higher-timeframe close; use the last completed higher-timeframe bar.
Calculation: Fibonacci midpoint = (lowest higher-timeframe low + highest higher-timeframe high) / 2 over the same lookback; use the last completed higher-timeframe bars.
Long: MACD line crosses above MACD signal line AND MACD line < long MACD threshold AND ADX > threshold AND higher-timeframe close < its simple moving average AND RSI < its simple moving average AND higher-timeframe close < Fibonacci midpoint
Short: MACD line crosses below MACD signal line AND MACD line > short MACD threshold AND ADX > threshold AND higher-timeframe close > its simple moving average AND RSI > its simple moving average AND higher-timeframe close > Fibonacci midpoint
Calculation: Long stop = entry price × (1 − maximum long loss) until the close reaches entry price × (1 + long trailing activation); thereafter, the greater of the previous long stop and close × (1 − long trailing distance).
Calculation: Short stop = entry price × (1 + maximum short loss) until the close reaches entry price × (1 − short trailing activation); thereafter, the lesser of the previous short stop and close × (1 + short trailing distance).
Exit: long, low ≤ long stop OR high ≥ entry price × (1 + long take profit)
Exit: short, high ≥ short stop OR low ≤ entry price × (1 − short take profit)