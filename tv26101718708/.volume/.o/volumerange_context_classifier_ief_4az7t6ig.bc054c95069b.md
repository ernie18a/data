Calculation: Volume z-score = (volume − its simple moving average over the baseline lookback) / its standard deviation over the same lookback
Calculation: True-range z-score = (true range − its simple moving average over the baseline lookback) / its standard deviation over the same lookback; use the same baseline lookback as for volume z-score
Calculation: Close location = (close − low) / max(high − low, minimum tick size)
Calculation: Directional body = abs(close − open) / max(high − low, minimum tick size)
Calculation: Prior structure high = highest high over the structure lookback, excluding the current bar
Calculation: Prior structure low = lowest low over the structure lookback, excluding the current bar
Long: Sufficient history for both z-scores and prior structure levels AND completed bar AND volume z-score >= its threshold AND true-range z-score >= its threshold AND close location >= its minimum AND close > prior structure high AND close >= EMA of close
Short: Sufficient history for both z-scores and prior structure levels AND completed bar AND volume z-score >= its threshold AND true-range z-score >= its threshold AND close location <= 1 − its minimum AND close < prior structure low AND close <= EMA of close