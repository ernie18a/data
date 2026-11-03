Calculation: Indicator sampling = evaluate each of the six configured timeframes on its current still-forming bar; each may be lower than, equal to, or higher than the chart timeframe.
Calculation: Moving average = linear weighted average of close; the fast average uses a shorter lookback than the slow average.
Calculation: MACD = fast EMA of close minus slow EMA of close, with a signal line formed by averaging the MACD line; the fast EMA uses a shorter lookback than the slow EMA.
Calculation: CCI = commodity channel index calculated from typical price (high + low + close) / 3.
Calculation: Stochastic main line = slow %K calculated from highs and lows with simple moving average smoothing.
Calculation: Trailing stop = for a long, set to the current price minus the trailing distance after price rises above entry by more than trailing distance plus step, if the existing stop is below current price minus trailing distance and step; for a short, mirror these comparisons and set it to current price plus the trailing distance.
Long: position side = flat AND on every configured timeframe fast moving average > slow moving average AND RSI > 50 AND CCI > 0 AND stochastic main line > 40 AND MACD line > signal line
Short: position side = flat AND on every configured timeframe fast moving average < slow moving average AND RSI < 50 AND CCI < 0 AND stochastic main line < 60 AND MACD line < signal line
Exit: long, low <= entry price - configured stop-loss distance OR high >= entry price + configured take-profit distance OR low <= trailing stop
Exit: short, high >= entry price + configured stop-loss distance OR low <= entry price - configured take-profit distance OR high >= trailing stop