Calculation: Candle body = abs(close - open)
Calculation: Candle range = high - low
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Body high = max(open, close)
Calculation: Body low = min(open, close)
Calculation: Body midpoint = (open + close) / 2
Calculation: Latest swing high = most recent confirmed Pivot High(high, pivot lookback, pivot lookback)
Calculation: Previous swing high = prior confirmed Pivot High(high, pivot lookback, pivot lookback)
Calculation: Latest swing low = most recent confirmed Pivot Low(low, pivot lookback, pivot lookback)
Calculation: Previous swing low = prior confirmed Pivot Low(low, pivot lookback, pivot lookback)
Calculation: Upward swing break = latest swing high exists AND close > latest swing high + ATR(ATR lookback) * break penetration AND close[1] <= latest swing high + ATR(ATR lookback) * break penetration
Calculation: Downward swing break = latest swing low exists AND close < latest swing low - ATR(ATR lookback) * break penetration AND close[1] >= latest swing low - ATR(ATR lookback) * break penetration
Calculation: Structure direction = neutral initially; bullish after an upward swing break, bearish after a downward swing break, otherwise unchanged
Long: Upward swing break
Short: Downward swing break
Long: Latest swing low exists AND low < latest swing low AND close > latest swing low AND close[1] > latest swing low
Short: Latest swing high exists AND high > latest swing high AND close < latest swing high AND close[1] < latest swing high
Short: Latest and previous swing highs and latest swing low exist AND latest swing low formed after the previous swing high and before the latest swing high AND abs(latest swing high - previous swing high) <= ATR(ATR lookback) * swing tolerance AND close < latest swing low AND close[1] >= latest swing low
Long: Latest and previous swing lows and latest swing high exist AND latest swing high formed after the previous swing low and before the latest swing low AND abs(latest swing low - previous swing low) <= ATR(ATR lookback) * swing tolerance AND close > latest swing high AND close[1] <= latest swing high
Long: Latest and previous swing highs and lows exist AND abs(latest swing high - previous swing high) <= ATR(ATR lookback) * swing tolerance AND latest swing low > previous swing low
Short: Latest and previous swing highs and lows exist AND abs(latest swing low - previous swing low) <= ATR(ATR lookback) * swing tolerance AND latest swing high < previous swing high
Long: close > open AND close[1] < open[1] AND close >= open[1] AND open <= close[1] AND Candle body > Candle body[1]
Short: close < open AND close[1] > open[1] AND close <= open[1] AND open >= close[1] AND Candle body > Candle body[1]
Long: close > open AND Candle range > 0 AND close[1] < open[1] AND open < close[1] AND close > Body midpoint[1] AND close < open[1] AND Candle body > Candle body[1] * minimum reversal-body fraction
Short: close < open AND Candle range > 0 AND close[1] > open[1] AND open > close[1] AND close < Body midpoint[1] AND close > open[1] AND Candle body > Candle body[1] * minimum reversal-body fraction
Long: Body high < Body high[1] AND Body low > Body low[1] AND open[1] > close[1] AND Candle body < Candle body[1] * maximum harami-body fraction
Short: Body high < Body high[1] AND Body low > Body low[1] AND open[1] < close[1] AND Candle body < Candle body[1] * maximum harami-body fraction
Long: close > open AND Candle range > 0 AND open - low <= Candle range * maximum belt-hold opening-wick fraction AND Candle body >= Candle range * minimum belt-hold body fraction AND Upper wick <= Candle range * maximum belt-hold opposite-wick fraction
Short: close < open AND Candle range > 0 AND high - open <= Candle range * maximum belt-hold opening-wick fraction AND Candle body >= Candle range * minimum belt-hold body fraction AND Lower wick <= Candle range * maximum belt-hold opposite-wick fraction
Long: close > open AND Candle range > 0 AND Candle body >= Candle range * minimum marubozu-body fraction
Short: close < open AND Candle range > 0 AND Candle body >= Candle range * minimum marubozu-body fraction
Long: high and high[1] differ by no more than ATR(ATR lookback) * tweezer tolerance AND close > open AND close[1] < open[1]
Short: high and high[1] differ by no more than ATR(ATR lookback) * tweezer tolerance AND close < open AND close[1] > open[1]
Long: close > open AND close[1] > open[1] AND close[2] > open[2] AND close > close[1] AND close[1] > close[2] AND open > open[1] AND open < close[1] AND open[1] > open[2] AND open[1] < close[2] AND Upper wick <= Candle body * maximum soldier opposite-wick fraction
Short: close < open AND close[1] < open[1] AND close[2] < open[2] AND close < close[1] AND close[1] < close[2] AND open < open[1] AND open > close[1] AND open[1] < open[2] AND open[1] > close[2] AND Lower wick <= Candle body * maximum soldier opposite-wick fraction
Long: close[2] < open[2] AND Candle body[2] > ATR(ATR lookback) * minimum star first-body ATR multiple AND Candle body[1] <= Candle body[2] * maximum star middle-body fraction AND close > open AND close > Body midpoint[2]
Short: close[2] > open[2] AND Candle body[2] > ATR(ATR lookback) * minimum star first-body ATR multiple AND Candle body[1] <= Candle body[2] * maximum star middle-body fraction AND close < open AND close < Body midpoint[2]
Long: close > open AND Candle range > 0 AND close[1] < open[1] AND open < close[1] AND close > Body midpoint[1] AND close < open[1] AND Candle body > Candle body[1] * minimum reversal-body fraction
Short: close < open AND Candle range > 0 AND close[1] > open[1] AND open > close[1] AND close < Body midpoint[1] AND close > open[1] AND Candle body > Candle body[1] * minimum reversal-body fraction
Long: close > open AND close[1] < open[1] AND abs(low - low[1]) <= ATR(ATR lookback) * tweezer tolerance
Short: close < open AND close[1] > open[1] AND abs(high - high[1]) <= ATR(ATR lookback) * tweezer tolerance
Long: Candle range > 0 AND Candle body > 0 AND Lower wick >= Candle body * minimum hammer lower-wick multiple AND Upper wick <= Candle body * maximum hammer opposite-wick fraction AND Structure direction != bullish
Short: Candle range > 0 AND Candle body > 0 AND Lower wick >= Candle body * minimum hammer lower-wick multiple AND Upper wick <= Candle body * maximum hammer opposite-wick fraction AND Structure direction = bullish
Long: Candle range > 0 AND Candle body > 0 AND Upper wick >= Candle body * minimum hammer lower-wick multiple AND Lower wick <= Candle body * maximum hammer opposite-wick fraction AND Structure direction = bearish
Short: Candle range > 0 AND Candle body > 0 AND Upper wick >= Candle body * minimum hammer lower-wick multiple AND Lower wick <= Candle body * maximum hammer opposite-wick fraction AND Structure direction != bearish
Long: high > high[1] AND low < low[1] AND close > open
Short: high > high[1] AND low < low[1] AND close <= open