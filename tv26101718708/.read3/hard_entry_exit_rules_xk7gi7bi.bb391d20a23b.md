Calculation: Premarket high = maximum(high) over current-date premarket chart bars
Calculation: Premarket low = minimum(low) over current-date premarket chart bars
Calculation: Current-date high = maximum(high) over current-date chart bars through the current bar
Calculation: Current-date low = minimum(low) over current-date chart bars through the current bar
Calculation: Level touch(level) = high >= level × (1 − touch tolerance) AND low <= level × (1 + touch tolerance)
Calculation: Bullish level retest(level) = low <= level × (1 + touch tolerance) AND close > level AND close > open
Calculation: Bearish level retest(level) = high >= level × (1 − touch tolerance) AND close < level AND close < open
Calculation: Bullish bounded-touch reaction(level) = Level touch(level) AND close > level AND close > open
Calculation: Bearish bounded-touch reaction(level) = Level touch(level) AND close < level AND close < open
Calculation: Captured long level = first enabled matching level in this order: bullish retest at the previous-T1 high, bullish retest at the premarket high, bullish bounded-touch reaction at the previous-T1 high, bullish bounded-touch reaction at the premarket high; none if no level setup matches
Calculation: Captured short level = first enabled matching level in this order: bearish retest at the previous-T1 low, bearish retest at the premarket low, bearish bounded-touch reaction at the previous-T1 low, bearish bounded-touch reaction at the premarket low; none if no level setup matches
Long: during the entry window AND flat AND daily entry count below its configured limit AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND (VWAP filter disabled OR close > VWAP(hlc3)) AND (EMA alignment filter disabled OR EMA(close, shorter lookback) > EMA(close, longer lookback)) AND (close > high of the last completed T1 bar, sampled on chart bars, OR close > premarket high) AND (enabled retest at an enabled previous-T1 or premarket high OR enabled bounded-touch reaction at an enabled previous-T1 or premarket high OR enabled EMA tap with low <= EMA(close, shorter lookback) AND close > open)
Short: during the entry window AND flat AND daily entry count below its configured limit AND close < EMA(close, shorter lookback) AND close < EMA(close, longer lookback) AND (VWAP filter disabled OR close < VWAP(hlc3)) AND (EMA alignment filter disabled OR EMA(close, shorter lookback) < EMA(close, longer lookback)) AND (close < low of the last completed T1 bar, sampled on chart bars, OR close < premarket low) AND (enabled retest at an enabled previous-T1 or premarket low OR enabled bounded-touch reaction at an enabled previous-T1 or premarket low OR enabled EMA tap with high >= EMA(close, shorter lookback) AND close < open)
Exit: Long, intrabar low <= EMA(close, longer lookback)
Exit: Short, intrabar high >= EMA(close, longer lookback)
Exit: Long, close < EMA(close, shorter lookback) OR (a long level was captured at entry AND close < that captured level)
Exit: Short, close > EMA(close, shorter lookback) OR (a short level was captured at entry AND close > that captured level)
Exit: Long, a partial trim order is active AND high > current-date high recorded on the entry bar
Exit: Short, a partial trim order is active AND low < current-date low recorded on the entry bar
Exit: Long, within the configured end-of-day flatten window
Exit: Short, within the configured end-of-day flatten window
Calculation: Premarket high = highest high during the premarket window
Calculation: Premarket low = lowest low during the premarket window
Calculation: Regular-session high = highest high since the regular-session open
Calculation: Regular-session low = lowest low since the regular-session open
Calculation: Bullish level touch = level exists AND high >= level × (1 − P3) AND low <= level × (1 + P3) AND close > level AND close > open
Calculation: Bearish level touch = level exists AND high >= level × (1 − P3) AND low <= level × (1 + P3) AND close < level AND close < open
Long: inside the entry window AND flat AND fewer than P4 entries today AND (VWAP alignment disabled OR close > VWAP((high + low + close) / 3)) AND (EMA alignment disabled OR EMA(close, P1) > EMA(close, P2)) AND close > EMA(close, P2) AND close > EMA(close, P1) AND ((enabled previous high on T1 exists AND close > previous high on T1) OR (enabled premarket high exists AND close > premarket high)) AND (close crosses above an enabled previous high on T1 or premarket high OR first-touch setup enabled AND bullish level touch of an enabled previous high on T1 or premarket high OR EMA-tap setup enabled AND low <= EMA(close, P1))
Short: inside the entry window AND flat AND fewer than P4 entries today AND (VWAP alignment disabled OR close < VWAP((high + low + close) / 3)) AND (EMA alignment disabled OR EMA(close, P1) < EMA(close, P2)) AND close < EMA(close, P2) AND close < EMA(close, P1) AND ((enabled previous low on T1 exists AND close < previous low on T1) OR (enabled premarket low exists AND close < premarket low)) AND (close crosses below an enabled previous low on T1 or premarket low OR first-touch setup enabled AND bearish level touch of an enabled previous low on T1 or premarket low OR EMA-tap setup enabled AND high >= EMA(close, P1))
Exit: long, close < EMA(close, P1) OR (entry level exists AND close < entry level) OR low <= EMA(close, P2) OR high > regular-session high at entry OR inside the end-of-day flatten window
Exit: short, close > EMA(close, P1) OR (entry level exists AND close > entry level) OR high >= EMA(close, P2) OR low < regular-session low at entry OR inside the end-of-day flatten window