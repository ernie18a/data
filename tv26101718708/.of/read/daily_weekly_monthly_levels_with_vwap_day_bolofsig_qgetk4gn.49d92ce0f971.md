Calculation: Prior levels = the high and low of the last completed bar for each of three successively higher timeframes; compare all historical chart-bar prices in a decision with the current bar's prior level.
Calculation: Session VWAP = cumulative sum of typical price times volume divided by cumulative volume since the current session began, where typical price = (high + low + close) / 3.
Calculation: Anchored VWAPs = cumulative sum of typical price times volume divided by cumulative volume from the start of each of the current, previous, and second-previous bars of a higher timeframe through the current chart bar.
Calculation: Trend gate = close is above each of five EMAs and three SMAs of the last completed bar of a higher timeframe; the five EMA lookbacks increase successively, and the SMA lookbacks equal the three longest EMA lookbacks.
Calculation: Recent session high = the elapsed time from the most recent bar whose high strictly exceeded all earlier highs in the current session, counting the first session bar as a new high.
Calculation: High break = for any prior high level, close and previous close are above that current level AND the close two bars ago is at or below that level.
Calculation: Low reclaim = for any prior low level, close is above that current level AND previous close is at or below it.
Calculation: High rejection = for any prior high level, high is at or above that current level AND close is below it AND previous high is below it.
Calculation: Low break = for any prior low level, close is below that current level AND previous close is at or above it.
Calculation: High failure = for any prior high level, close is below that current level AND previous close is above it.
Calculation: Short sweep = high failure AND the number of bars since the most recent high break is at most a sweep-window parameter; the broken and failed levels need not be the same.
Calculation: Staged event = high break OR low reclaim OR high rejection OR low break OR short sweep.
Long: High break.
Long: Low reclaim.
Long: For any prior high or low level, previous close > current level AND low <= current level AND close >= current level AND (trend gate is false OR recent session high <= a time threshold).
Long: For any anchored VWAP, close >= current anchored VWAP AND (previous close < current anchored VWAP OR (previous close >= current anchored VWAP AND low <= current anchored VWAP)) AND (trend gate is false OR recent session high <= a time threshold).
Long: Close is above the session open for exactly the confirmation number of consecutive bars AND a prior close crossed below the session open from at or above it after a close above the open in the same session AND no confirmed open reclaim has occurred since that cross.
Long: Low >= session open AND low <= session open times one plus a tolerance AND close > session open AND close > open AND no low has been below the session open in the current session AND no close has crossed below the session open from at or above it after a close above it in the current session without a subsequent confirmed open reclaim AND this clean hold has not previously occurred in the current session.
Long: Low < session open AND close > session open AND close > open AND no close has crossed below the session open from at or above it after a close above it in the current session without a subsequent confirmed open reclaim AND this wick reclaim has not previously occurred in the current session.
Long: Each of the preceding setup-lookback bars closed below its own session VWAP AND close > session VWAP AND close > open AND close < the prior high of the shortest higher timeframe.
Long: Each of the preceding setup-lookback bars closed above its own session VWAP AND low <= session VWAP times one plus a tolerance AND close > session VWAP AND close > open.
Long: For any prior high or low level of either of the two longer higher timeframes, close > level AND close > open AND no staged event occurs AND either (low >= level AND low <= level times one plus a tolerance AND no low has been below that level since the session began or the level changed AND this clean hold has not previously occurred since that reset) OR (low < level AND this wick reclaim has not previously occurred since that reset); clean-hold and wick-reclaim occurrences are recorded even when a staged event suppresses the alert.
Short: High rejection.
Short: Low break AND short sweep is false.
Short: Short sweep.
Short: Each of the preceding setup-lookback bars closed above its own session VWAP AND close < session VWAP AND close < open AND close > the prior low of the shortest higher timeframe.