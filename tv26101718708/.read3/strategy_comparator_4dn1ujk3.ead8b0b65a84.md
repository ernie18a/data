Calculation: Moving-average rating(x) = 1 when close > x, -1 when close < x, otherwise 0.
Calculation: Signed RWI(p) = ((high - low[p]) - (high[p] - low)) / ((high[p] - low[p]) * sqrt(p)).
Calculation: Composite rating = the selected moving-average mean, oscillator mean, or their mean. The moving-average mean averages moving-average ratings for SMA and EMA at six distinct increasing lookbacks, HMA at its lookback, VWMA at its lookback, and the Ichimoku rating. The Ichimoku conversion line and base line are the midpoints of the highest high and lowest low over their respective lookbacks; Span A is the midpoint of those lines; Span B is the midpoint of the highest high and lowest low over its lookback. The Ichimoku rating is 1 when Span A > Span B, close > Span A, close < base line, close[1] < conversion line, and close > conversion line; -1 when Span A < Span B, close < Span B, close > base line, close[1] > conversion line, and close < conversion line; otherwise 0. The oscillator mean averages 11 ratings: RSI is 1 below its lower threshold, -1 above its upper threshold, otherwise 0; Stochastic is 1 when %K and %D are below the lower threshold and %K > %D, -1 when %K is above the upper threshold and %K < %D, otherwise 0; CCI is 1 when below its lower threshold and rising, -1 when above its upper threshold and falling, otherwise 0; DMI/ADX is 1 when ADX is above its threshold, +DI > -DI, and prior +DI < prior -DI, -1 when ADX is above its threshold, +DI < -DI, and prior +DI > prior -DI, otherwise 0; Awesome Oscillator is 1 when AO > 0, AO[1] > 0, AO > AO[1], and AO[2] > AO[1], or when AO > 0 and AO[1] < 0; -1 when AO < 0, AO[1] < 0, AO < AO[1], and AO[2] < AO[1], or when AO < 0 and AO[1] > 0; otherwise 0; Momentum is 1 when MOM(close, lookback) < MOM(close, lookback)[1], -1 when greater, otherwise 0; MACD is 1 when its line > its signal line, -1 when less, otherwise 0; Stochastic RSI is 1 when close < EMA(close, trend lookback), its smoothed %K and %D are below their lower threshold, %K > %D, and prior %K < prior %D; -1 when close > that EMA, both are above their upper threshold, %K < %D, and prior %K > prior %D; otherwise 0; Williams %R is 1 below its lower threshold and rising, -1 above its upper threshold and falling, otherwise 0; Elder-Ray rating is 1 when close > EMA(close, trend lookback), low - EMA(close, lookback) < 0 and rising, -1 when close < that trend EMA, high - EMA(close, lookback) > 0 and falling, otherwise 0; Ultimate Oscillator is 1 above its upper threshold, -1 below its lower threshold, otherwise 0. The composite rating uses the selected group of moving averages, oscillators, or both.
Calculation: Cumulative wick imbalance = rolling sum over a lookback of (upper wick - lower wick) / (ATR(lookback) * multiplier), where upper wick = high - close when close >= open, otherwise high - open; lower wick = close - low when close <= open, otherwise open - low.
Long: Bollinger Bands mean-reversion or midline-exit mode, close crosses above the lower band, and the side setting permits long.
Short: Bollinger Bands mean-reversion or midline-exit mode, close crosses below the upper band, and the side setting permits short.
Exit: Long, Bollinger Bands midline-exit mode and close crosses above the middle band.
Exit: Short, Bollinger Bands midline-exit mode and close crosses below the middle band.
Long: Bollinger Bands breakout mode, close > upper band, and the side setting permits long.
Short: Bollinger Bands breakout mode, close < lower band, and the side setting permits short.
Exit: Long, Bollinger Bands breakout mode and close <= upper band and (the side setting is long-only or close >= lower band).
Exit: Short, Bollinger Bands breakout mode and close >= lower band and (the side setting is short-only or close <= upper band).
Long: close > EMA(close, Keltner lookback) + ATR(Keltner lookback) * multiplier and the side setting permits long.
Short: close < EMA(close, Keltner lookback) - ATR(Keltner lookback) * multiplier and the side setting permits short.
Long: SMA(close, fast lookback) >= SMA(close, slow lookback) and the side setting permits long.
Short: SMA(close, fast lookback) < SMA(close, slow lookback) and the side setting permits short.
Long: MACD(close, fast lookback, slow lookback, signal lookback) line >= signal line and the side setting permits long.
Short: MACD(close, fast lookback, slow lookback, signal lookback) line < signal line and the side setting permits short.
Long: close > close[lookback] and the side setting permits long.
Short: close < close[lookback] and the side setting permits short.
Long: high > highest(high[1], lookback) and the side setting permits long.
Short: low < lowest(low[1], lookback) and the side setting permits short.
Long: RSI(close, lookback) crosses above its lower threshold and the side setting permits long.
Short: RSI(close, lookback) crosses below its upper threshold and the side setting permits short.
Exit: Long, RSI threshold-cross-with-exits mode, RSI crosses above its upper threshold, or the side setting is long-only and RSI crosses below its lower threshold.
Exit: Short, RSI threshold-cross-with-exits mode, RSI crosses below its lower threshold, or the side setting is short-only and RSI crosses above its upper threshold.
Long: RSI level mode, RSI > upper threshold and the side setting permits long.
Short: RSI level mode, RSI < lower threshold and the side setting permits short.
Exit: Long, RSI level mode, RSI <= upper threshold and (the side setting is long-only or RSI >= lower threshold).
Exit: Short, RSI level mode, RSI >= lower threshold and (the side setting is short-only or RSI <= upper threshold).
Long: Signed RWI(fast lookback) > 0 and Signed RWI(slow lookback) >= 0 and the side setting permits long.
Short: Signed RWI(fast lookback) < 0 and Signed RWI(slow lookback) <= 0 and the side setting permits short.
Long: high >= high[1] and low <= low[1] and close > open and the side setting permits long.
Short: high >= high[1] and low <= low[1] and close < open and the side setting permits short.
Long: close is higher than each of the prior closes for the up-count lookback and the side setting permits long.
Short: close is lower than each of the prior closes for the down-count lookback and the side setting permits short.
Long: Supertrend(ATR lookback, multiplier) direction is bullish and the side setting permits long.
Short: Supertrend(ATR lookback, multiplier) direction is bearish and the side setting permits short.
Long: Composite rating > selected weak-or-strong threshold and the side setting permits long.
Short: Composite rating < the negative of the selected weak-or-strong threshold and the side setting permits short.
Exit: Long, Composite rating is not above the selected threshold and (the side setting is long-only or Composite rating is not below the negative threshold).
Exit: Short, Composite rating is not below the negative threshold and (the side setting is short-only or Composite rating is not above the selected threshold).
Long: close crosses above Parabolic SAR(start parameter, acceleration parameter, maximum parameter) and the side setting permits long.
Short: close crosses below Parabolic SAR(start parameter, acceleration parameter, maximum parameter) and the side setting permits short.
Long: smoothed Stochastic %K crosses above smoothed %D while %K is below the oversold threshold, and the side setting permits long.
Short: smoothed Stochastic %K crosses below smoothed %D while %K is above the overbought threshold, and the side setting permits short.
Long: Cumulative wick imbalance > threshold, it does not cross zero, and the side setting permits long.
Short: Cumulative wick imbalance < -threshold, it does not cross zero, and the side setting permits short.
Exit: Long, Cumulative wick imbalance crosses zero.
Exit: Short, Cumulative wick imbalance crosses zero.