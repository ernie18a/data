Calculation: confirmed swing highs and lows = the latest and preceding confirmed pivot highs and lows, each pivot using the swing lookback parameter on both sides.
Calculation: bullish swing structure = latest confirmed swing high > preceding confirmed swing high AND latest confirmed swing low > preceding confirmed swing low.
Calculation: bearish swing structure = latest confirmed swing high < preceding confirmed swing high AND latest confirmed swing low < preceding confirmed swing low.
Calculation: equal swing highs = both latest and preceding confirmed swing highs exist AND absolute difference between them / close * 100 < equal-pivot tolerance parameter.
Calculation: equal swing lows = both latest and preceding confirmed swing lows exist AND absolute difference between them / close * 100 < equal-pivot tolerance parameter.
Calculation: bullish sweep = a preceding confirmed swing low exists AND low < that swing low AND close > that swing low.
Calculation: bearish sweep = a preceding confirmed swing high exists AND high > that swing high AND close < that swing high.
Calculation: bullish accumulation mark = bullish sweep AND min(open, close) - low > abs(close - open) * wick/body ratio parameter AND close > open AND volume > SMA(volume, volume-average lookback) AND MFI(hlc3, MFI lookback) > its value on the previous chart bar.
Calculation: bearish distribution mark = bearish sweep AND high - max(open, close) > abs(close - open) * wick/body ratio parameter AND close < open AND volume > SMA(volume, volume-average lookback) AND MFI(hlc3, MFI lookback) < its value on the previous chart bar.
Calculation: bullish FVG retest = on a later chart bar after the latest bullish gap, where that gap formed when low > high at the gap-lookback parameter bars ago and stored current low as its top and that earlier high as its bottom, current low <= stored top AND close > stored bottom.
Calculation: bearish FVG retest = on a later chart bar after the latest bearish gap, where that gap formed when high < low at the gap-lookback parameter bars ago and stored that earlier low as its top and current high as its bottom, current high >= stored bottom AND close < stored top.
Calculation: bullish order-block retest = after storing the high and low of the most recent bearish candle whenever close exceeds the latest confirmed swing high, current low <= stored high AND close >= stored low.
Calculation: bearish order-block retest = after storing the high and low of the most recent bullish candle whenever close falls below the latest confirmed swing low, current high >= stored low AND close <= stored high.
Calculation: swing range = absolute difference between the latest confirmed swing high and latest confirmed swing low, when both exist.
Calculation: bullish Fibonacci zone = low <= latest confirmed swing high - swing range * shallow retracement parameter AND close >= latest confirmed swing high - swing range * deep retracement parameter.
Calculation: bearish Fibonacci zone = high >= latest confirmed swing low + swing range * shallow retracement parameter AND close <= latest confirmed swing low + swing range * deep retracement parameter.
Calculation: bullish EMA/Fibonacci proximity = absolute difference between EMA(close, EMA lookback) and (latest confirmed swing high - swing range * middle retracement parameter) / close * 100 <= EMA/Fibonacci distance parameter.
Calculation: bearish EMA/Fibonacci proximity = absolute difference between EMA(close, EMA lookback) and (latest confirmed swing low + swing range * middle retracement parameter) / close * 100 <= EMA/Fibonacci distance parameter.
Calculation: bullish retracement confluence = bullish Fibonacci zone AND (bullish FVG retest OR bullish order-block retest OR bullish EMA/Fibonacci proximity OR bullish sweep).
Calculation: bearish retracement confluence = bearish Fibonacci zone AND (bearish FVG retest OR bearish order-block retest OR bearish EMA/Fibonacci proximity OR bearish sweep).
Calculation: wait for bullish pullback = close > close at the strong-move lookback parameter bars ago AND (close - that earlier close) / that earlier close * 100 >= strong-move percentage parameter AND NOT bullish retracement confluence.
Calculation: wait for bearish pullback = close < close at the strong-move lookback parameter bars ago AND (that earlier close - close) / that earlier close * 100 >= strong-move percentage parameter AND NOT bearish retracement confluence.
Calculation: long directional bias = close > EMA(close, EMA lookback) AND EMA(close, EMA lookback) > its value on the previous chart bar AND bullish swing structure AND RSI(close, RSI lookback) > RSI midpoint parameter AND MACD line > signal line AND MACD histogram > its value on the previous chart bar AND NOT equal swing highs AND NOT bearish distribution mark; MACD uses a shorter lookback, a longer lookback, and a signal lookback.
Calculation: short directional bias = close < EMA(close, EMA lookback) AND EMA(close, EMA lookback) < its value on the previous chart bar AND bearish swing structure AND RSI(close, RSI lookback) < RSI midpoint parameter AND MACD line < signal line AND MACD histogram < its value on the previous chart bar AND NOT equal swing lows AND NOT bullish accumulation mark; MACD uses a shorter lookback, a longer lookback, and a signal lookback.
Calculation: long setup = on a confirmed chart bar, long directional bias AND bullish retracement confluence AND volume > SMA(volume, volume-average lookback) AND close > open AND close > high on the previous chart bar AND NOT wait for bullish pullback.
Calculation: short setup = on a confirmed chart bar, short directional bias AND bearish retracement confluence AND volume > SMA(volume, volume-average lookback) AND close < open AND close < low on the previous chart bar AND NOT wait for bearish pullback.
Long: bullish accumulation mark.
Short: bearish distribution mark.
Long: wait for bullish pullback.
Short: wait for bearish pullback.
Long: long directional bias AND NOT long setup AND NOT wait for bullish pullback.
Short: short directional bias AND NOT short setup AND NOT wait for bearish pullback.
Long: long setup.
Short: short setup.
Long: long setup AND NOT long setup on the previous chart bar.
Short: short setup AND NOT short setup on the previous chart bar.