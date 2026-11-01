Calculation: Crosses above means current value > current reference AND previous value <= previous reference; crosses below means current value < current reference AND previous value >= previous reference.
Calculation: Random-walk difference at lookback N = ((high - low N bars ago) - (high N bars ago - low)) / ((high N bars ago - low N bars ago) * sqrt(N)); use a shorter and a longer lookback.
Calculation: Wick imbalance = rolling sum of (upper wick - lower wick) / (ATR * multiplier), where upper wick = high - max(open, close) and lower wick = min(open, close) - low.
Calculation: Aggregate rating = the selected moving-average rating, oscillator rating, or their equal-weight average. Each component rating is +1 for its listed positive condition, -1 for its listed negative condition, and otherwise 0; positive takes precedence if both apply. The moving-average rating is the mean of ratings for SMA and EMA at six increasingly longer lookbacks, HMA, VWMA, and Ichimoku. For each moving average, its rating is +1 if close > average and -1 if close < average. For Ichimoku, use unshifted conversion, base, span A and span B: positive if span A > span B AND close > span A AND close < base AND previous close < current conversion AND close > conversion; negative if span A < span B AND close < span B AND close > base AND previous close > current conversion AND close < conversion. The oscillator rating is the mean of the following component ratings: RSI is positive below a lower threshold and negative above an upper threshold; stochastic is positive when K and D are below a lower threshold AND K > D, and negative when K > an upper threshold AND K < D; CCI is positive below a lower threshold AND rising, and negative above an upper threshold AND falling; ADX is positive above a strength threshold AND +DI > -DI AND previous +DI < previous -DI, and negative above that threshold AND +DI < -DI AND previous +DI > previous -DI; awesome oscillator is positive when it and its previous value are positive AND it is rising AND its previous value is below its value two bars ago, OR when it is positive AND its previous value is negative, and negative under the symmetric conditions; momentum is positive when falling and negative when rising; MACD is positive when its line > signal and negative when its line < signal; stochastic RSI is positive when close < trend EMA AND K and D < lower threshold AND K > D AND previous K < previous D, and negative when close > trend EMA AND K and D > upper threshold AND K < D AND previous K > previous D; Williams %R is positive below a lower threshold AND rising and negative above an upper threshold AND falling; bulls/bears power is positive when close > trend EMA AND bear power < 0 AND rising, and negative when close < trend EMA AND bull power > 0 AND falling; ultimate oscillator is positive above an upper threshold and negative below a lower threshold. Use a shorter and a longer moving average for the awesome oscillator and short, intermediate and long lookbacks for the ultimate oscillator.
Long: Close crosses above the lower Bollinger Band.
Short: Close crosses below the upper Bollinger Band.
Exit: long, close crosses above the Bollinger middle band AND the middle-band-exit behavior is selected.
Exit: short, close crosses below the Bollinger middle band AND the middle-band-exit behavior is selected.
Long: Close > upper Bollinger Band AND breakout behavior is selected.
Short: Close < lower Bollinger Band AND breakout behavior is selected.
Exit: long, close <= upper Bollinger Band AND breakout behavior is selected.
Exit: short, close >= lower Bollinger Band AND breakout behavior is selected.
Long: Close > EMA of close + ATR * multiplier.
Short: Close < EMA of close - ATR * multiplier.
Long: Shorter-lookback SMA of close >= longer-lookback SMA of close.
Short: Shorter-lookback SMA of close < longer-lookback SMA of close.
Long: MACD line >= signal line.
Short: MACD line < signal line.
Long: Close > close at the momentum lookback.
Short: Close < close at the momentum lookback.
Long: High > highest high over the preceding lookback, excluding the current bar.
Short: Low < lowest low over the preceding lookback, excluding the current bar.
Long: RSI crosses above its lower threshold AND mean-reversion behavior is selected.
Short: RSI crosses below its upper threshold AND mean-reversion behavior is selected.
Exit: long, RSI crosses above its upper threshold OR RSI crosses below its lower threshold, AND the threshold-exit behavior is selected.
Exit: short, RSI crosses above its upper threshold OR RSI crosses below its lower threshold, AND the threshold-exit behavior is selected.
Long: RSI > upper threshold AND breakout behavior is selected.
Short: RSI < lower threshold AND breakout behavior is selected.
Exit: long, RSI <= upper threshold AND breakout behavior is selected.
Exit: short, RSI >= lower threshold AND breakout behavior is selected.
Long: Shorter-lookback random-walk difference > 0 AND longer-lookback random-walk difference >= 0.
Short: Shorter-lookback random-walk difference < 0 AND longer-lookback random-walk difference <= 0.
Long: High >= previous high AND low <= previous low AND close > open.
Short: High >= previous high AND low <= previous low AND close < open.
Long: Count of consecutive bars with close > previous close >= the up-count threshold.
Short: Count of consecutive bars with close < previous close >= the down-count threshold.
Long: Supertrend indicates an uptrend.
Short: Supertrend indicates a downtrend.
Long: Aggregate rating > positive rating threshold.
Short: Aggregate rating < negative rating threshold.
Exit: long, aggregate rating <= positive rating threshold.
Exit: short, aggregate rating >= negative rating threshold.
Long: Close crosses above parabolic SAR.
Short: Close crosses below parabolic SAR.
Long: Slow stochastic K crosses above slow stochastic D AND K < oversold threshold.
Short: Slow stochastic K crosses below slow stochastic D AND K > overbought threshold.
Long: Wick imbalance > positive threshold AND wick imbalance does not cross zero on the same bar.
Short: Wick imbalance < negative threshold AND wick imbalance does not cross zero on the same bar.
Exit: long, wick imbalance crosses above zero OR crosses below zero.
Exit: short, wick imbalance crosses above zero OR crosses below zero.
Exit: long, the active strategy's short condition is met AND short entries are disabled.
Exit: short, the active strategy's long condition is met AND long entries are disabled.