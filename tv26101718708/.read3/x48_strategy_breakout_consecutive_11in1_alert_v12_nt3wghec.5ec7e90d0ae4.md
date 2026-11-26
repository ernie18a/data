Calculation: Range threshold = multiplier * stdev(high - low, range-length lookback) + sma(high - low, range-length lookback)
Calculation: ATR-channel average(source, lookback, multiplier) = average(maximum, minimum), where distance = ATR(lookback) * multiplier; upper candidate = (high + low) / 2 + distance; lower candidate = (high + low) / 2 - distance; upper = source[1] < upper[1] ? min(upper candidate, upper[1]) : upper candidate; lower = source[1] > lower[1] ? max(lower candidate, lower[1]) : lower candidate; direction = source > upper ? bullish : source < lower ? bearish : direction[1]; stop = direction is bullish ? lower : upper; maximum = source crosses stop OR direction is bullish ? max(source, maximum[1]) : stop; minimum = source crosses stop OR direction is bearish ? min(source, minimum[1]) : stop; upper, lower, direction, maximum, and minimum initialize to zero
Calculation: ATR trail(close, ATR lookback, multiplier) = let distance = ATR(lookback) * multiplier and prior trail = trail[1] or zero; if close > prior trail and close[1] > prior trail, max(prior trail, close - distance); else if close < prior trail and close[1] < prior trail, min(prior trail, close + distance); else if close > prior trail, close - distance; otherwise close + distance
Long: sufficient breakout-lookback history AND high >= highest(high, breakout lookback)[1] + minimum price increment
Long: sufficient breakout-lookback history AND high >= highest(high, breakout lookback)[1] + minimum price increment AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0
Long: sufficient breakout-lookback history AND high >= highest(high, breakout lookback)[1] + minimum price increment AND RSI(close, RSI lookback) <= RSI overbought threshold
Long: sufficient breakout-lookback history AND high >= highest(high, breakout lookback)[1] + minimum price increment AND MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type)
Long: sufficient breakout-lookback history AND high >= highest(high, breakout lookback)[1] + minimum price increment AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) > ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Long: sufficient breakout-lookback history AND high >= highest(high, breakout lookback)[1] + minimum price increment AND Aroon Up(high, Aroon lookback) > Aroon Down(low, same Aroon lookback)
Short: low <= lowest(low, breakout lookback)[1] - minimum price increment
Short: low <= lowest(low, breakout lookback)[1] - minimum price increment AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0
Short: low <= lowest(low, breakout lookback)[1] - minimum price increment AND RSI(close, RSI lookback) >= RSI oversold threshold
Short: low <= lowest(low, breakout lookback)[1] - minimum price increment AND MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type)
Short: low <= lowest(low, breakout lookback)[1] - minimum price increment AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Short: low <= lowest(low, breakout lookback)[1] - minimum price increment AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Long: close > close[1] for the up-count parameter consecutive chart bars
Long: close > close[1] for the up-count parameter consecutive chart bars AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0
Long: close > close[1] for the up-count parameter consecutive chart bars AND RSI(close, RSI lookback) <= RSI overbought threshold
Long: close > close[1] for the up-count parameter consecutive chart bars AND MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type)
Long: close > close[1] for the up-count parameter consecutive chart bars AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) > ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Long: close > close[1] for the up-count parameter consecutive chart bars AND Aroon Up(high, Aroon lookback) > Aroon Down(low, same Aroon lookback)
Short: close < close[1] for the down-count parameter consecutive chart bars
Short: close < close[1] for the down-count parameter consecutive chart bars AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0
Short: close < close[1] for the down-count parameter consecutive chart bars AND RSI(close, RSI lookback) >= RSI oversold threshold
Short: close < close[1] for the down-count parameter consecutive chart bars AND MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type)
Short: close < close[1] for the down-count parameter consecutive chart bars AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Short: close < close[1] for the down-count parameter consecutive chart bars AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Long: high - low > Range threshold AND close > close[1] for the range-direction lookback
Long: high - low > Range threshold AND close > close[1] for the range-direction lookback AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0
Long: high - low > Range threshold AND close > close[1] for the range-direction lookback AND RSI(close, RSI lookback) <= RSI overbought threshold
Long: high - low > Range threshold AND close > close[1] for the range-direction lookback AND MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type)
Long: high - low > Range threshold AND close > close[1] for the range-direction lookback AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) > ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Long: high - low > Range threshold AND close > close[1] for the range-direction lookback AND Aroon Up(high, Aroon lookback) > Aroon Down(low, same Aroon lookback)
Exit: long, high - low > Range threshold AND close < close[1] for the range-direction lookback
Exit: long, high - low > Range threshold AND close < close[1] for the range-direction lookback AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0
Exit: long, high - low > Range threshold AND close < close[1] for the range-direction lookback AND RSI(close, RSI lookback) >= RSI oversold threshold
Exit: long, high - low > Range threshold AND close < close[1] for the range-direction lookback AND MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type)
Exit: long, high - low > Range threshold AND close < close[1] for the range-direction lookback AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Exit: long, high - low > Range threshold AND close < close[1] for the range-direction lookback AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Exit: short, high - low > Range threshold AND close < close[1] for the range-direction lookback
Exit: short, high - low > Range threshold AND close < close[1] for the range-direction lookback AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0
Exit: short, high - low > Range threshold AND close < close[1] for the range-direction lookback AND RSI(close, RSI lookback) >= RSI oversold threshold
Exit: short, high - low > Range threshold AND close < close[1] for the range-direction lookback AND MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type)
Exit: short, high - low > Range threshold AND close < close[1] for the range-direction lookback AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Exit: short, high - low > Range threshold AND close < close[1] for the range-direction lookback AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Long: MA(selected source, shorter lookback, selected type) crosses above MA(selected source, longer lookback, selected type)
Short: MA(selected source, shorter lookback, selected type) crosses below MA(selected source, longer lookback, selected type)
Long: MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type)
Short: MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type)
Long: MA(selected source, shorter lookback, selected type) crosses above MA(selected source, longer lookback, selected type) AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0
Short: MA(selected source, shorter lookback, selected type) crosses below MA(selected source, longer lookback, selected type) AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0
Long: MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type) AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0
Short: MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type) AND MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0
Long: MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type) AND RSI(close, RSI lookback) <= RSI overbought threshold
Short: MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type) AND RSI(close, RSI lookback) >= RSI oversold threshold
Long: MA(selected source, shorter lookback, selected type) crosses above MA(selected source, longer lookback, selected type) AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) > ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Short: MA(selected source, shorter lookback, selected type) crosses below MA(selected source, longer lookback, selected type) AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Long: MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type) AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) > ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Short: MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type) AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Long: MA(selected source, shorter lookback, selected type) crosses above MA(selected source, longer lookback, selected type) AND Aroon Up(high, Aroon lookback) > Aroon Down(low, same Aroon lookback)
Short: MA(selected source, shorter lookback, selected type) crosses below MA(selected source, longer lookback, selected type) AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Long: MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type) AND Aroon Up(high, Aroon lookback) > Aroon Down(low, same Aroon lookback)
Short: MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type) AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses above zero
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses below zero
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses above zero AND RSI(close, RSI lookback) <= RSI overbought threshold
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses below zero AND RSI(close, RSI lookback) >= RSI oversold threshold
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0 AND RSI(close, RSI lookback) <= RSI overbought threshold
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0 AND RSI(close, RSI lookback) >= RSI oversold threshold
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses above zero AND MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type)
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses below zero AND MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type)
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0 AND MA(selected source, shorter lookback, selected type) > MA(selected source, longer lookback, selected type)
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0 AND MA(selected source, shorter lookback, selected type) < MA(selected source, longer lookback, selected type)
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses above zero AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) > ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses below zero AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0 AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) > ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0 AND ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) < ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses above zero AND Aroon Up(high, Aroon lookback) > Aroon Down(low, same Aroon lookback)
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) crosses below zero AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Long: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) > 0 AND Aroon Up(high, Aroon lookback) > Aroon Down(low, same Aroon lookback)
Short: MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) < 0 AND Aroon Up(high, Aroon lookback) < Aroon Down(low, same Aroon lookback)
Long: ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) crosses above ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Short: ATR-channel average(close, shorter Tenkan lookback, Tenkan multiplier) crosses below ATR-channel average(close, longer Kijun lookback, Kijun multiplier)
Exit: long, close < most recent nonmissing PivotLow(low, pivot-left lookback, pivot-right lookback) shifted by the pivot-delay parameter
Exit: short, close > most recent nonmissing PivotHigh(high, pivot-left lookback, pivot-right lookback) shifted by the pivot-delay parameter
Exit: short, ATR trail(close, shorter ATR lookback, fast ATR multiplier) crosses above ATR trail(close, longer ATR lookback, slow ATR multiplier)
Exit: long, ATR trail(close, shorter ATR lookback, fast ATR multiplier) crosses below ATR trail(close, longer ATR lookback, slow ATR multiplier)
Exit: long, (long take-profit parameter > 0 AND high reaches entry price increased by the long take-profit percentage) OR (shared stop-loss parameter > 0 AND low reaches entry price decreased by the shared stop-loss percentage)
Exit: short, (short take-profit parameter > 0 AND low reaches entry price decreased by the short take-profit percentage) OR (shared stop-loss parameter > 0 AND high reaches entry price increased by the shared stop-loss percentage)
Exit: long, close from T1's bar still forming, sampled on chart bars <= highest(high, breakout lookback) decreased by the breakout callback percentage
Exit: short, close from T1's bar still forming, sampled on chart bars >= lowest(low, breakout lookback) increased by the breakout callback percentage
Exit: long, open profit >= profit threshold
Exit: short, open profit >= profit threshold
Exit: long, close from T1's bar still forming, sampled on chart bars <= entry price
Exit: short, close from T1's bar still forming, sampled on chart bars >= entry price