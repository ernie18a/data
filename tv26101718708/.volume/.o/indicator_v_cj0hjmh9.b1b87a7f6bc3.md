Calculation: Bullish engulfing = candle body ≥ displacement threshold × ATR, close > open, close in upper 35% of range, close > prior open, open < prior close, and volume ≥ volume average × volume threshold
Calculation: Bearish engulfing = candle body ≥ displacement threshold × ATR, close < open, close in lower 35% of range, close < prior open, open > prior close, and volume ≥ volume average × volume threshold
Calculation: Liquidity high/low = highest high / lowest low over the liquidity lookback, excluding the current bar
Calculation: Low sweep = prior bar low ≤ liquidity low and current close > liquidity low; high sweep = prior bar high ≥ liquidity high and current close < liquidity high
Calculation: Bullish/bearish fair value gap = on the chart timeframe, current low > high two bars earlier / current high < low two bars earlier, with gap size ≥ 0.05% of close
Calculation: Hourly and daily bullish/bearish fair value gaps = on the last completed hourly/daily bars, the previous bar's low > high two bars earlier / high < low two bars earlier, with gap size ≥ the configured percentage of current close
Calculation: Bullish/bearish gap entry = a bullish/bearish chart-timeframe gap formed within the prior 50 bars; close is within that gap; and a bullish/bearish engulfing occurs
Calculation: Range break = after a range is established from a lookback of bars whose high-to-low span ≤ ATR × range-height threshold, close crosses above its high / below its low, open is on the other side, and candle body ≥ 0.5 × ATR
Calculation: Structure proximity = close is within the configured ATR distance of prior-day low/high, weekly open, daily open, or the midpoint of a bullish/bearish hourly/daily gap; use the last completed prior day and last completed hourly/daily bars, and the current week's/day's forming open
Calculation: Structure flip = bullish/bearish engulfing and bullish/bearish structure proximity
Calculation: Volume spike = volume ≥ volume moving average × volume threshold
Calculation: Relative-strength difference = instrument return over the relative-strength lookback minus correlated instrument return over the same lookback
Calculation: Correlated low/high sweep = correlated instrument's prior bar low ≤ its prior liquidity low and current close > that low / prior bar high ≥ its prior liquidity high and current close < that high
Calculation: Long/short score = sum of: +1 for matching higher-timeframe sweep bias; +1 in either configured session; +1 for volume spike; +1 for matching correlated sweep; +1 when relative-strength difference is positive/negative; +1 for matching hourly gap unless killed by an opposing daily gap at least 1.5× larger and within 300 points; +1 for matching daily gap; +1 near prior-day low/high; +1 when daily VIX close is below/above its prior completed daily close; +1 after at least two same-side liquidity sweeps; +1 for matching structure proximity; +2 for matching structure flip; +2 for matching gap entry. Cap each score at 10. Higher-timeframe bias is the latest direction of a higher-timeframe liquidity sweep, using the higher-timeframe lookback high/low excluding its current bar.
Calculation: Dominant side = side with the higher score; score gap = absolute score difference; worth calling = dominant score ≥ 6 or dominant score ≥ 4 and score gap ≥ 2
Calculation: Long stop = liquidity low − ATR × stop-distance threshold, captured on a low sweep; short stop = liquidity high + ATR × stop-distance threshold, captured on a high sweep
Long: low sweep AND long score ≥ minimum score
Long: long score ≥ 8
Long: short score ≤ 3 AND long score ≥ 5
Long: low sweep AND worth calling AND long score > short score
Long: high sweep AND long score > short score AND long score ≥ 5
Long: low sweep has occurred and close > highest high over the prior 10 bars, excluding the current bar
Long: structure flip
Long: bullish gap entry
Long: bullish range break AND volume spike
Short: high sweep AND short score ≥ minimum score
Short: short score ≥ 8
Short: long score ≤ 3 AND short score ≥ 5
Short: high sweep AND worth calling AND short score > long score
Short: low sweep AND short score > long score AND short score ≥ 5
Short: high sweep has occurred and close < lowest low over the prior 10 bars, excluding the current bar
Short: structure flip
Short: bearish gap entry
Short: bearish range break AND volume spike
Exit: Long, close < captured long stop
Exit: Short, close > captured short stop