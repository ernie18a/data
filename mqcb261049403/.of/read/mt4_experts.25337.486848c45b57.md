Calculation: Fast moving average = simple moving average of close over a shorter lookback on the chart timeframe, using the last completed bar
Calculation: Slow moving average = simple moving average of close over a longer lookback on the chart timeframe, using the last completed bar
Long: No open strategy positions AND fast moving average < slow moving average AND higher-timeframe MACD main line > MACD signal line, using the last completed higher-timeframe bar
Short: No open strategy positions AND fast moving average > slow moving average AND higher-timeframe MACD main line < MACD signal line, using the last completed higher-timeframe bar
Long: In a short-start recovery sequence, ask > previous short entry price + recovery zone; OR in a long-start recovery sequence, ask > initial long entry price after a recovery short
Short: In a long-start recovery sequence, bid < initial long entry price - recovery zone; OR in a short-start recovery sequence, bid < initial short entry price after a recovery long
Exit: long, high >= order take-profit price OR low <= order stop-loss price
Exit: short, low <= order take-profit price OR high >= order stop-loss price