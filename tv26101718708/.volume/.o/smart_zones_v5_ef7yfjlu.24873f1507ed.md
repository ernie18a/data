Calculation: ATR = average true range over a lookback
Calculation: Volume spike = current volume >= its moving average over a lookback multiplied by a threshold
Calculation: Bullish engulfing = bullish candle with body >= ATR × threshold, close in the upper part of its range, close > previous open, open < previous close, and volume spike
Calculation: Bearish engulfing = bearish candle with body >= ATR × threshold, close in the lower part of its range, close < previous open, open > previous close, and volume spike
Calculation: Prior rolling high/low = highest high / lowest low over a lookback, excluding the current bar
Calculation: Low sweep = previous bar's low <= prior rolling low and current close > prior rolling low
Calculation: High sweep = previous bar's high >= prior rolling high and current close < prior rolling high
Calculation: Bullish fair value gap = current low > high two bars ago and the gap is at least a minimum size; bearish fair value gap = current high < low two bars ago and the gap is at least a minimum size
Calculation: HTF sweep bias = on the selected higher timeframe, a prior bar sweeps the prior rolling high/low and the current higher-timeframe close returns below/above that level; use the current higher-timeframe bar for its high, low, and close, and exclude the current bar from the rolling levels
Calculation: Correlated-instrument sweep = same low/high sweep condition on the configured correlated instrument, using bars matching the chart timeframe
Calculation: Relative strength = chart close return over a lookback minus correlated-instrument close return over the same lookback
Calculation: Prior-day high/low = high/low of the last completed daily bar
Calculation: Weekly/daily open = open of the weekly/daily bar still forming
Calculation: Hourly bullish/bearish fair value gap = gap between the last completed hourly bar and the hourly bar two bars before it, meeting the minimum size; midpoint is the average of the gap edges
Calculation: Daily bullish/bearish fair value gap = gap between the last completed daily bar and the daily bar two bars before it, meeting the minimum size; midpoint is the average of the gap edges
Calculation: At long structure = close is within a volatility-based distance of prior-day low, weekly open, daily open, hourly bullish-gap midpoint, or daily bullish-gap midpoint; at short structure uses prior-day high, either open, hourly bearish-gap midpoint, or daily bearish-gap midpoint
Calculation: Long structure flip = bullish engulfing and at long structure; short structure flip = bearish engulfing and at short structure
Calculation: Recent bullish/bearish gap entry = within a limited number of bars after a chart-timeframe gap, close is within that gap and a matching bullish/bearish engulfing occurs
Calculation: Range breakout = while a tracked range is active, close crosses above its high or below its low, open is on the other side, and candle body >= ATR × threshold; range is formed from a rolling high-low whose height is <= ATR × threshold
Calculation: Long BOS confirmation = after a low sweep, close > the highest high over a lookback excluding the current bar; short BOS confirmation = after a high sweep, close < the lowest low over that lookback
Calculation: Long sweep count = consecutive low-sweep count, reset by a new rolling swing high or a high sweep; short sweep count is the converse
Calculation: Daily FVG dominance = daily gap size >= 1.5 × opposing hourly gap size and close is within a fixed distance of the relevant daily gap edge
Calculation: Long confluence score = sum of points for bullish HTF bias, in-session status, volume spike, correlated low sweep, positive relative strength, non-cancelled hourly bullish gap, daily bullish gap, proximity to prior-day low, falling VIX, at least two low sweeps, at long structure, long structure flip, and recent bullish gap entry; the last two add two points each; cap at 10
Calculation: Short confluence score = sum of points for bearish HTF bias, in-session status, volume spike, correlated high sweep, negative relative strength, non-cancelled hourly bearish gap, daily bearish gap, proximity to prior-day high, rising VIX, at least two high sweeps, at short structure, short structure flip, and recent bearish gap entry; the last two add two points each; cap at 10
Calculation: Conflict = bullish chart-timeframe gap and high sweep, or bearish chart-timeframe gap and low sweep
Calculation: Long stop = prior rolling low minus ATR × stop multiplier, captured on low sweep; short stop = prior rolling high plus ATR × stop multiplier, captured on high sweep
Calculation: Long target = highest high over a lookback, captured on the sweep bar; short target = lowest low over a lookback, captured on the sweep bar
Long: bullish engulfing
Long: low sweep
Long: bullish chart-timeframe fair value gap
Long: bullish hourly fair value gap
Long: bullish daily fair value gap
Long: range breakout above range high AND volume spike
Long: long structure flip
Long: recent bullish gap entry
Long: long BOS confirmation
Long: low sweep AND long confluence score >= minimum score
Long: long confluence score >= 8
Long: short confluence score <= 3 AND long confluence score >= 5
Long: low sweep AND long confluence score > short confluence score AND (dominant score >= 6 OR (dominant score >= 4 AND score gap >= 2))
Short: bearish engulfing
Short: high sweep
Short: bearish chart-timeframe fair value gap
Short: bearish hourly fair value gap
Short: bearish daily fair value gap
Short: range breakout below range low AND volume spike
Short: short structure flip
Short: recent bearish gap entry
Short: short BOS confirmation
Short: high sweep AND short confluence score >= minimum score
Short: short confluence score >= 8
Short: long confluence score <= 3 AND short confluence score >= 5
Short: high sweep AND short confluence score > long confluence score AND (dominant score >= 6 OR (dominant score >= 4 AND score gap >= 2))
Exit: Long, close < active long stop
Exit: Short, close > active short stop
Exit: Long, high >= long target
Exit: Short, low <= short target