Calculation: score = sum each criterion's positive score weight when true and negative score weight when false: MACD line > signal line; RSI > bullish threshold AND RSI <= overbought threshold; ADX > strength threshold AND +DI > -DI; close > EMA(close, short EMA lookback); close > EMA(close, long EMA lookback); SuperTrend bullish; volume > SMA(volume, volume lookback) × high-volume multiplier
Calculation: dip upper boundary = EMA(close, long EMA lookback) - ATR(ATR lookback) × (dip ATR multiple - zone half-width)
Calculation: peak lower boundary = EMA(close, short EMA lookback) + ATR(ATR lookback) × (peak ATR multiple - zone half-width)
Calculation: regular dip signal = SuperTrend bullish AND close < dip upper boundary AND MACD line > signal line AND RSI > bullish threshold AND RSI <= overbought threshold AND score >= regular dip score minimum
Calculation: strong dip signal = SuperTrend bullish AND close < dip upper boundary AND MACD line > signal line AND RSI > bullish threshold AND volume > SMA(volume, volume lookback) × high-volume multiplier AND score >= strong dip score minimum
Calculation: regular peak signal = SuperTrend bearish AND close > peak lower boundary AND MACD line <= signal line AND RSI <= overbought threshold AND score <= regular peak score maximum
Calculation: strong peak signal = SuperTrend bearish AND close > peak lower boundary AND MACD line <= signal line AND RSI <= bullish threshold AND volume > SMA(volume, volume lookback) × high-volume multiplier AND score <= strong peak score maximum
Calculation: main long signal = SuperTrend bullish AND MACD line > signal line AND RSI > bullish threshold AND RSI <= overbought threshold AND ADX > strength threshold AND +DI > -DI AND close > EMA(close, short EMA lookback) AND close > EMA(close, long EMA lookback) AND score >= long entry score minimum
Calculation: main short signal = SuperTrend bearish AND MACD line <= signal line AND RSI <= bullish threshold AND ADX > strength threshold AND +DI <= -DI AND close <= EMA(close, short EMA lookback) AND close <= EMA(close, long EMA lookback) AND score <= short entry score maximum
Calculation: falling pivot-high resistance = line through the latest two confirmed PivotHigh(high, pivot lookback, pivot lookback) points when the older pivot high is higher
Calculation: long stop = on a rising edge of a regular dip signal, strong dip signal, or main long signal, set to SuperTrend value; otherwise, while set and SuperTrend is bullish, update to the greater of the previous stop and SuperTrend value; clear when close < stop
Calculation: take-profit targets = on a rising edge of a regular or strong dip signal, set each target to lowest(low, target base lookback) + ATR(ATR lookback) × its target distance; on a rising edge of the main long signal when target one is unset or hit, set each target to close + ATR(ATR lookback) × its target distance; mark each target hit when high >= it and clear all targets when all are hit
Long: MACD line > signal line
Short: MACD line <= signal line
Long: RSI > bullish threshold
Short: RSI <= bullish threshold
Long: ADX > strength threshold AND +DI > -DI
Short: ADX > strength threshold AND +DI <= -DI
Long: close > EMA(close, short EMA lookback)
Short: close <= EMA(close, short EMA lookback)
Long: close > EMA(close, long EMA lookback)
Short: close <= EMA(close, long EMA lookback)
Long: SuperTrend bullish
Short: SuperTrend bearish
Long: score >= dashboard buy score threshold
Short: score < dashboard neutral score threshold
Long: regular dip signal
Long: strong dip signal
Short: regular peak signal
Short: strong peak signal
Long: main long signal AND NOT main long signal one bar ago
Short: main short signal AND NOT main short signal one bar ago
Long: crosses above falling pivot-high resistance
Long: Trade Zone display enabled AND close one bar ago < lower Bollinger Band one bar ago AND current close is within Bollinger Bands(close, Trade Zone lookback, deviation multiplier)
Long: Heikin-Ashi close > Heikin-Ashi open
Short: Heikin-Ashi close <= Heikin-Ashi open
Exit: long, close < long stop
Exit: long, target one is active and unhit AND high >= target one
Exit: long, target two is active and unhit AND high >= target two
Exit: long, target three is active and unhit AND high >= target three