Calculation: cumulative positive flow = previous cumulative positive flow plus hlc3 * volume when hlc3 > prior-bar hlc3, otherwise previous cumulative positive flow; initialize at zero
Calculation: cumulative negative flow = previous cumulative negative flow plus hlc3 * volume when hlc3 < prior-bar hlc3, otherwise previous cumulative negative flow; initialize at zero
Calculation: custom flow index = 100 - 100 / (1 + SMA(cumulative positive flow, flow lookback) / SMA(cumulative negative flow, same flow lookback))
Calculation: smoothed RSI-flow average = EMA((custom flow index + RSI(close, RSI lookback)) / 2, smoothing lookback)
Calculation: cascade average = WMA(EMA(WMA(EMA(hlc3, first lookback), second lookback), third lookback), fourth lookback)
Long: Williams %R(high, low, close, lookback) crosses above the oversold threshold
Short: Williams %R(high, low, close, lookback) crosses below the overbought threshold
Long: RSI(close, RSI lookback) > RSI midpoint threshold
Short: RSI(close, RSI lookback) < RSI midpoint threshold
Long: CCI(close, lookback) crosses above the lower CCI threshold
Short: CCI(close, lookback) crosses below the upper CCI threshold
Long: custom flow index crosses above the oversold flow threshold
Short: custom flow index crosses below the overbought flow threshold
Long: MACD histogram with shorter fast, slow, and signal lookbacks crosses above zero
Short: MACD histogram with shorter fast, slow, and signal lookbacks crosses below zero
Long: MACD histogram with longer fast, slow, and signal lookbacks crosses above zero
Short: MACD histogram with longer fast, slow, and signal lookbacks crosses below zero
Long: close crosses above EMA(close, band lookback) - deviation multiplier * stdev(close, band lookback)
Short: close crosses below EMA(close, band lookback) + deviation multiplier * stdev(close, band lookback)
Long: close crosses above EMA(close, channel lookback) - EMA(selected true range or high-low range, same channel lookback) * channel multiplier
Short: close crosses below EMA(close, channel lookback) + EMA(selected true range or high-low range, same channel lookback) * channel multiplier
Long: close > Parabolic SAR(start, increment, maximum)
Short: close < Parabolic SAR(start, increment, maximum)
Exit: long, close crosses below Parabolic SAR(start, increment, maximum)
Exit: short, close crosses above Parabolic SAR(start, increment, maximum)
Long: smoothed RSI-flow average > a rung and its prior-bar value < the same rung, for any rung in a threshold ladder defined by lower rung, upper rung, and interval
Short: smoothed RSI-flow average < a rung and its prior-bar value > the same rung, for any rung in a threshold ladder defined by lower rung, upper rung, and interval
Long: close > cascade average OR (prior-bar hlc3 < cascade average AND hlc3 > cascade average AND smoothed RSI-flow average > a rung and its prior-bar value < the same rung, for any rung in the threshold ladder)
Short: close < cascade average OR (prior-bar hlc3 > cascade average AND hlc3 < cascade average AND smoothed RSI-flow average < a rung and its prior-bar value > the same rung, for any rung in the threshold ladder)
Long: Ichimoku Span A(conversion lookback, base lookback) > Ichimoku Span B(span-B lookback)
Short: Ichimoku Span A(conversion lookback, base lookback) < Ichimoku Span B(span-B lookback)
Long: on chart bars, MACD line using the longer fast and slow lookbacks and Heikin-Ashi close is above its signal line on the last completed bar of each of four ascending timeframes T1, T2, T3, and T4
Short: on chart bars, MACD line using the longer fast and slow lookbacks and Heikin-Ashi close is below its signal line on the last completed bar of each of four ascending timeframes T1, T2, T3, and T4