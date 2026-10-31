Calculation: Relative close movement = absolute close-to-previous-close change divided by the mean absolute close-to-previous-close change over the preceding lookback, expressed as a percentage and rounded to a whole number.
Calculation: MACD comparison flag = 1 if both the current and previous MACD main values are nonzero, otherwise 0.
Long: Shorter-period linear-weighted moving average of chart close > longer-period simple moving average of chart close.
Short: Shorter-period linear-weighted moving average of chart close < longer-period simple moving average of chart close.
Long: Chart close > chart parabolic SAR.
Short: Chart close < chart parabolic SAR.
Exit: long, chart close < chart parabolic SAR.
Exit: short, chart close > chart parabolic SAR.
Long: Moving average of close on the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, > its previous-bar value.
Short: Moving average of close on the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, < its previous-bar value.
Short: Any of the multiple independently evaluated moving averages of close on the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, <= its previous-bar value.
Long: Chart close > previous chart close AND relative close movement >= minimum directional threshold.
Short: Chart close < previous chart close AND relative close movement >= minimum directional threshold.
Long: Chart MACD main > previous MACD main AND MACD comparison flag != current signal line AND NOT (MACD main > zero AND previous MACD main < zero) AND NOT (MACD main < zero AND previous MACD main > zero) AND NOT (MACD main < signal line AND previous MACD main > previous signal line).
Long: Chart MACD main > signal line AND previous MACD main < previous signal line AND NOT (MACD main > zero AND previous MACD main < zero) AND NOT (MACD main < zero AND previous MACD main > zero).
Short: Chart MACD main < previous MACD main AND MACD comparison flag != current signal line AND NOT (MACD main > signal line AND previous MACD main < previous signal line) AND NOT (MACD main > zero AND previous MACD main < zero) AND NOT (MACD main < zero AND previous MACD main > zero).
Short: Chart MACD main < signal line AND previous MACD main > previous signal line AND NOT (MACD main < previous MACD main AND MACD comparison flag != current signal line) AND NOT (MACD main > zero AND previous MACD main < zero) AND NOT (MACD main < zero AND previous MACD main > zero).
Long: Chart MACD main > zero AND previous MACD main < zero.
Short: Chart MACD main < zero AND previous MACD main > zero.
Long: On the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, MACD main < zero AND MACD main > signal line AND previous MACD main < previous signal line.
Short: On the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, MACD main > zero AND MACD main < signal line AND previous MACD main > previous signal line.
Long: On the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, stochastic main <= oversold threshold AND stochastic main > previous stochastic main AND stochastic main >= stochastic signal.
Short: On the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, stochastic main >= overbought threshold AND stochastic main < previous stochastic main AND stochastic main <= stochastic signal.
Long: On the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, RSI of close, CCI of close, money flow index, or Williams %R <= that indicator's oversold threshold AND the same indicator > its previous-bar value.
Short: On the chart timeframe or a higher or lower timeframe, using the bar still forming and the preceding completed bar, RSI of close, CCI of close, money flow index, or Williams %R >= that indicator's overbought threshold AND the same indicator < its previous-bar value.
Long: Chart close < lower Bollinger Band of close on the chart timeframe or a higher or lower timeframe using its bar still forming AND chart close > previous chart close.
Short: Chart close > upper Bollinger Band of close on the chart timeframe or a higher or lower timeframe using its bar still forming AND chart close < previous chart close.