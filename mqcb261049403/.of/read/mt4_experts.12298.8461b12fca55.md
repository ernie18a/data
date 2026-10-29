Long: Flat position AND stochastic %K < oversold level AND stochastic %D < %K AND higher-timeframe EMA with shorter lookback > higher-timeframe EMA with longer lookback AND close < RSI AND RSI < oversold threshold AND trading weekday enabled AND date is outside the year-end blackout AND Bollinger band widths meet the minimum and maximum volatility limits
Short: Flat position AND stochastic %K > overbought level AND stochastic %D < %K AND higher-timeframe EMA with shorter lookback < higher-timeframe EMA with longer lookback AND close > RSI AND RSI > overbought threshold AND trading weekday enabled AND date is outside the year-end blackout AND Bollinger band widths meet the minimum and maximum volatility limits
Long: Current position is short AND RSI > short-exit threshold AND stop-and-reverse is enabled
Short: Current position is long AND RSI < long-exit threshold AND stop-and-reverse is enabled
Exit: Long, RSI < long-exit threshold
Exit: Short, RSI > short-exit threshold