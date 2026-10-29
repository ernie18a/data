Calculation: Stochastic RSI %K = stochastic of RSI over its lookback; %D = moving average of %K over its smoothing lookback
Calculation: Long pending = becomes true when %K and %D are below the oversold level, the MACD line is negative and lower than its values on each of the prior two bars, and close < open; remains true until a long signal, then becomes false
Calculation: Short pending = becomes true when %K and %D are above the overbought level, the MACD line is positive and higher than its values on each of the prior two bars, and close > open; remains true until a short signal, then becomes false
Long: Long pending AND close > open
Short: Short pending AND close < open