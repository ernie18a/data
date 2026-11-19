Calculation: Higher-timeframe high = highest(high, HTF lookback) on T1, sampled on chart bars from the last completed T1 bar
Calculation: Higher-timeframe low = lowest(low, HTF lookback) on T1, sampled on chart bars from the last completed T1 bar
Calculation: Latest pivot high = latest confirmed pivot high(high, pivot strength bars on each side) on chart bars
Calculation: Latest pivot low = latest confirmed pivot low(low, pivot strength bars on each side) on chart bars
Calculation: Bullish sweep level = higher-timeframe low if low < higher-timeframe low and close > higher-timeframe low; otherwise latest pivot low if low < latest pivot low and close > latest pivot low; otherwise undefined
Calculation: Bearish sweep level = higher-timeframe high if high > higher-timeframe high and close < higher-timeframe high; otherwise latest pivot high if high > latest pivot high and close < latest pivot high; otherwise undefined
Calculation: Relative volume = volume / SMA(volume, volume lookback) when the SMA is positive, otherwise 0
Calculation: Lower wick fraction = (min(open, close) - low) / (high - low) when high > low, otherwise 0
Calculation: Upper wick fraction = (high - max(open, close)) / (high - low) when high > low, otherwise 0
Calculation: Bullish raw candidate = completed chart bar, bullish sweep level is defined, ATR(lookback) > 0, SMA(volume, volume lookback) > 0, relative volume >= minimum relative volume, (bullish sweep level - low) / ATR(lookback) <= maximum sweep penetration in ATR, and lower wick fraction >= minimum rejection wick fraction
Calculation: Bearish raw candidate = completed chart bar, bearish sweep level is defined, ATR(lookback) > 0, SMA(volume, volume lookback) > 0, relative volume >= minimum relative volume, (high - bearish sweep level) / ATR(lookback) <= maximum sweep penetration in ATR, and upper wick fraction >= minimum rejection wick fraction
Calculation: Bullish candidate = bullish raw candidate AND NOT bearish raw candidate
Calculation: Bearish candidate = bearish raw candidate AND NOT bullish raw candidate
Calculation: Latest bullish candidate age, sweep level, and high = bars since and values at the most recent bullish candidate
Calculation: Latest bearish candidate age, sweep level, and low = bars since and values at the most recent bearish candidate
Calculation: Bullish displacement = completed chart bar, latest bullish candidate age is between 1 and confirmation window, close > open, abs(close - open) >= ATR(lookback) * absorption displacement ATR multiplier, close > latest bullish candidate high, and close > highest(high[1], absorption structure lookback)
Calculation: Bearish displacement = completed chart bar, latest bearish candidate age is between 1 and confirmation window, close < open, abs(close - open) >= ATR(lookback) * absorption displacement ATR multiplier, close < latest bearish candidate low, and close < lowest(low[1], absorption structure lookback)
Calculation: Latest bullish displacement age, held level, and body midpoint = bars since and values at the most recent bullish displacement; held level is the latest bullish candidate sweep level at that displacement, and body midpoint is (open + close) / 2 on that displacement bar
Calculation: Latest bearish displacement age, held level, and body midpoint = bars since and values at the most recent bearish displacement; held level is the latest bearish candidate sweep level at that displacement, and body midpoint is (open + close) / 2 on that displacement bar
Long: completed chart bar AND latest bullish displacement age = 1 AND close > latest bullish displacement held level AND close >= latest bullish displacement body midpoint
Short: completed chart bar AND latest bearish displacement age = 1 AND close < latest bearish displacement held level AND close <= latest bearish displacement body midpoint