Calculation: RSI Z-score = (RSI − moving average of RSI) ÷ standard deviation of RSI, using the same lookback for both
Calculation: Liquidity level = lowest low of the prior lookback bars, excluding the current bar
Calculation: Stop price = entry price − ATR × stop multiple
Calculation: TP1 price = entry price + ATR × first target multiple
Calculation: TP2 price = entry price + ATR × second target multiple
Long: close > chart-timeframe long-term EMA AND chart-timeframe short-term EMA > chart-timeframe long-term EMA AND (higher-timeframe close > higher-timeframe long-term EMA AND higher-timeframe short-term EMA > higher-timeframe long-term EMA AND higher-timeframe RSI > threshold, using the still-forming higher-timeframe bar) AND ADX > threshold AND volume > moving average of volume × multiplier AND low < liquidity level AND close > liquidity level AND a liquidity sweep occurred within the lookback window AND close > liquidity level AND previous-bar RSI Z-score < threshold AND current RSI Z-score crossed above threshold AND close > previous close AND close < chart-timeframe short-term EMA + ATR × extension multiple
Exit: long, low ≤ stop price OR high ≥ TP1 price
Exit: long, low ≤ stop price OR high ≥ TP2 price
Exit: long, close < chart-timeframe long-term EMA