Calculation: bar range = high - low
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: bearish progress = max(0, close - open)
Calculation: bullish progress = max(0, open - close)
Calculation: bar delta = volume * (bar range > 0 ? ((close - low) - (high - close)) / bar range : 0)
Calculation: positive delta = max(0, bar delta)
Calculation: negative delta = abs(min(0, bar delta))
Calculation: delta average = SMA(abs(bar delta), volume lookback)
Calculation: volume average = SMA(volume, volume lookback)
Calculation: chart ATR = ATR(ATR lookback)
Calculation: reference high = highest(high[1], swing lookback)
Calculation: reference low = lowest(low[1], swing lookback)
Calculation: session VWAP = VWAP(hlc3)
Calculation: VWAP deviation = standard deviation(close, deviation lookback)
Calculation: HTF high, low, and ATR = high, low, and ATR(ATR lookback) on T1, sampled on chart bars from the last completed T1 bar historically and the still-forming T1 bar in realtime
Calculation: previous T2 and T3 highs and lows = each timeframe's high and low from its last completed bar, sampled on chart bars
Calculation: bearish sweep = high > reference high AND close < reference high AND high - reference high <= chart ATR * maximum sweep distance AND bar range > 0 AND upper wick / bar range >= minimum wick ratio
Calculation: bullish sweep = low < reference low AND close > reference low AND reference low - low <= chart ATR * maximum sweep distance AND bar range > 0 AND lower wick / bar range >= minimum wick ratio
Calculation: bearish reclaim = bars since (high > reference high) <= acceptance window AND close < reference high
Calculation: bullish reclaim = bars since (low < reference low) <= acceptance window AND close > reference low
Calculation: bearish absorption = positive delta >= delta average * delta multiplier AND volume >= volume average * volume expansion multiplier AND bearish progress <= chart ATR * maximum progress
Calculation: bullish absorption = negative delta >= delta average * delta multiplier AND volume >= volume average * volume expansion multiplier AND bullish progress <= chart ATR * maximum progress
Calculation: bearish divergence = bar delta >= highest(bar delta, divergence lookback)[1] AND close < highest(close, divergence lookback)[1]
Calculation: bullish divergence = bar delta <= lowest(bar delta, divergence lookback)[1] AND close > lowest(close, divergence lookback)[1]
Calculation: bearish score = clamp(IF(bearish sweep, sweep weight, 0) + IF(bearish reclaim, reclaim weight, 0) + IF(positive delta >= delta average * delta multiplier, delta weight, 0) + IF(volume >= volume average * volume expansion multiplier, volume weight, 0) + IF(bearish absorption, absorption weight, 0) + IF(bearish divergence, divergence weight, 0) + IF(volume >= volume average * large-volume multiplier AND bearish progress <= chart ATR * maximum progress AND upper wick >= bar range * large-wick ratio, large-trade weight, 0) + IF(min(abs(high - reference high), abs(low - reference low), abs(high - previous T2 high), abs(low - previous T2 low), abs(high - previous T3 high), abs(low - previous T3 low), abs(high - HTF high), abs(low - HTF low)) <= HTF ATR * HTF proximity multiplier, proximity weight, 0) + IF((high >= session VWAP AND close < session VWAP) OR (high >= session VWAP + VWAP deviation AND close < session VWAP + VWAP deviation), VWAP rejection weight, 0) + IF(close < low[1] OR (close < reference high AND bar delta <= 0), confirmation weight, 0) + IF(volume < volume[1] AND volume[1] < volume[2] AND bar range < chart ATR * narrow-range multiplier, narrow-range weight, 0) - IF(bearish sweep AND bearish reclaim AND NOT bearish absorption AND NOT bearish divergence, overlap deduction, 0), score floor, score cap)
Calculation: bullish score = clamp(IF(bullish sweep, sweep weight, 0) + IF(bullish reclaim, reclaim weight, 0) + IF(negative delta >= delta average * delta multiplier, delta weight, 0) + IF(volume >= volume average * volume expansion multiplier, volume weight, 0) + IF(bullish absorption, absorption weight, 0) + IF(bullish divergence, divergence weight, 0) + IF(volume >= volume average * large-volume multiplier AND bullish progress <= chart ATR * maximum progress AND lower wick >= bar range * large-wick ratio, large-trade weight, 0) + IF(min(abs(high - reference high), abs(low - reference low), abs(high - previous T2 high), abs(low - previous T2 low), abs(high - previous T3 high), abs(low - previous T3 low), abs(high - HTF high), abs(low - HTF low)) <= HTF ATR * HTF proximity multiplier, proximity weight, 0) + IF((low <= session VWAP AND close > session VWAP) OR (low <= session VWAP - VWAP deviation AND close > session VWAP - VWAP deviation), VWAP rejection weight, 0) + IF(close > high[1] OR (close > reference low AND bar delta >= 0), confirmation weight, 0) + IF(volume < volume[1] AND volume[1] < volume[2] AND bar range < chart ATR * narrow-range multiplier, narrow-range weight, 0) - IF(bullish sweep AND bullish reclaim AND NOT bullish absorption AND NOT bullish divergence, overlap deduction, 0), score floor, score cap)
Long: bullish score >= entry score threshold
Short: bearish score >= entry score threshold
Long: bullish score >= score color threshold
Short: bearish score >= score color threshold