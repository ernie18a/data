Calculation: Directional score = add the bullish score weight for each true condition and the bearish score weight otherwise: MACD line > signal line; RSI > bullish threshold AND RSI <= overbought threshold; ADX > strength threshold AND +DI > -DI; close > short EMA; close > long EMA; SuperTrend bullish; volume > SMA(volume, lookback) × high-volume multiplier.
Calculation: Nearest Fibonacci level = the level nearest to close among the five retracement levels between highest(high, lookback) and lowest(low, lookback), with ties resolved toward the shallower retracement.
Calculation: Descending pivot-high line = the line through the latest two confirmed pivot highs when the older pivot high is greater than the newer one, extrapolated to the current bar.
Calculation: Dip-zone band = the range from long EMA - ATR(lookback) × (dip-zone multiplier + near offset) to long EMA - ATR(lookback) × (dip-zone multiplier - near offset).
Calculation: Deep-dip band = the range from long EMA - ATR(lookback) × (dip-zone multiplier + far offset) to long EMA - ATR(lookback) × (dip-zone multiplier + near offset).
Calculation: Top-zone band = the range from short EMA + ATR(lookback) × (top-zone multiplier - near offset) to short EMA + ATR(lookback) × (top-zone multiplier + near offset).
Calculation: Extreme-top band = the range from short EMA + ATR(lookback) × (top-zone multiplier + near offset) to short EMA + ATR(lookback) × (top-zone multiplier + far offset).
Calculation: Next Heikin-Ashi open = (current Heikin-Ashi open + current Heikin-Ashi close) / 2.
Calculation: Long trailing stop = SuperTrend value on each fresh full-long signal; while active and SuperTrend is bullish, the greater of the prior stop and current SuperTrend value; cleared when close falls below it.
Calculation: Profit targets = on a new dip signal, lowest low over target lookback + ATR(lookback) × each target's separate multiplier; on a fresh full-long signal when target 1 is unset or hit, close + ATR(lookback) × each target's separate multiplier; each target stays active until high reaches it, and all targets clear on a new dip signal or after all are hit.
Long: MACD line > signal line.
Short: MACD line <= signal line.
Long: RSI > bullish threshold.
Short: RSI <= bullish threshold.
Long: ADX > strength threshold AND +DI > -DI.
Short: ADX > strength threshold AND +DI <= -DI.
Long: close > EMA(close, shorter lookback).
Short: close <= EMA(close, shorter lookback).
Long: close > EMA(close, longer lookback).
Short: close <= EMA(close, longer lookback).
Long: SuperTrend is bullish.
Short: SuperTrend is bearish.
Long: SuperTrend changes from bearish on the previous bar to bullish on the current bar.
Short: SuperTrend changes from bullish on the previous bar to bearish on the current bar.
Long: close >= nearest Fibonacci level AND close < nearest Fibonacci level + ATR(lookback).
Short: close < nearest Fibonacci level AND close > nearest Fibonacci level - ATR(lookback).
Long: close is within the dip-zone band.
Long: close is within the deep-dip band.
Short: close is within the top-zone band.
Short: close is within the extreme-top band.
Long: RSI > bullish threshold AND directional score >= general-buy threshold.
Short: directional score < neutral threshold.
Long: trade-zone display is enabled AND close[1] < lower Bollinger Band(close, lookback, multiplier)[1] AND current close is between the current lower and upper Bollinger Bands, inclusive.
Long: close > the descending pivot-high line AND close[1] <= that line's value on the previous bar.
Long: Heikin-Ashi close > Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open.
Long: HA overlay is enabled AND Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi low = Heikin-Ashi open.
Short: HA overlay is enabled AND Heikin-Ashi close <= Heikin-Ashi open AND Heikin-Ashi high = Heikin-Ashi open.
Long: HA overlay is enabled AND Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi close[1] <= Heikin-Ashi open[1].
Short: HA overlay is enabled AND Heikin-Ashi close <= Heikin-Ashi open AND Heikin-Ashi close[1] > Heikin-Ashi open[1].
Long: HA overlay is enabled AND Heikin-Ashi close <= Heikin-Ashi open AND Heikin-Ashi close > next Heikin-Ashi open AND NOT (Heikin-Ashi close[1] <= Heikin-Ashi open[1] AND Heikin-Ashi close[1] > next Heikin-Ashi open[1]).
Short: HA overlay is enabled AND Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi close < next Heikin-Ashi open AND NOT (Heikin-Ashi close[1] > Heikin-Ashi open[1] AND Heikin-Ashi close[1] < next Heikin-Ashi open[1]).
Long: SuperTrend is bullish AND close < long EMA - ATR(lookback) × (dip-zone multiplier - near offset) AND MACD line > signal line AND RSI > bullish threshold AND RSI <= overbought threshold AND directional score >= dip threshold.
Long: SuperTrend is bullish AND close < long EMA - ATR(lookback) × (dip-zone multiplier - near offset) AND MACD line > signal line AND RSI > bullish threshold AND RSI <= overbought threshold AND volume > SMA(volume, lookback) × high-volume multiplier AND directional score >= strong-dip threshold.
Short: SuperTrend is bearish AND close > short EMA + ATR(lookback) × (top-zone multiplier - near offset) AND MACD line <= signal line AND RSI <= overbought threshold AND directional score <= top threshold.
Short: SuperTrend is bearish AND close > short EMA + ATR(lookback) × (top-zone multiplier - near offset) AND MACD line <= signal line AND RSI <= bullish threshold AND volume > SMA(volume, lookback) × high-volume multiplier AND directional score <= strong-top threshold.
Long: SuperTrend is bullish AND MACD line > signal line AND RSI > bullish threshold AND RSI <= overbought threshold AND ADX > strength threshold AND +DI > -DI AND close > both EMAs AND directional score >= full-long threshold AND this condition is false on the previous bar.
Short: SuperTrend is bearish AND MACD line <= signal line AND RSI <= bullish threshold AND ADX > strength threshold AND +DI <= -DI AND close <= both EMAs AND directional score <= full-short threshold AND this condition is false on the previous bar.
Exit: Long, close < long trailing stop.
Exit: Long, first profit target is active and unhit AND high >= first profit target.
Exit: Long, second profit target is active and unhit AND high >= second profit target.
Exit: Long, third profit target is active and unhit AND high >= third profit target.