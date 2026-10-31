Calculation: MACD component for a selected OHLC field = shorter-period moving average of that field minus longer-period moving average of the same field, using the same selectable smoothing method and its parameters for both averages.
Calculation: Signal line = a selectable moving average of the MACD component of a selectable open, high, low, or close field, using independently selectable smoothing parameters.
Long: MACD component of close > MACD component of open.
Short: MACD component of close < MACD component of open.
Long: Signal line > previous bar's signal line.
Short: Signal line < previous bar's signal line.
Long: On a selectable higher or lower timeframe, the last completed bar's MACD component of close > its MACD component of open AND the preceding bar's MACD component of close <= its MACD component of open.
Short: On a selectable higher or lower timeframe, the last completed bar's MACD component of close < its MACD component of open AND the preceding bar's MACD component of close >= its MACD component of open.
Exit: long, on a selectable higher or lower timeframe, the last completed bar's MACD component of close < its MACD component of open.
Exit: short, on a selectable higher or lower timeframe, the last completed bar's MACD component of close > its MACD component of open.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.