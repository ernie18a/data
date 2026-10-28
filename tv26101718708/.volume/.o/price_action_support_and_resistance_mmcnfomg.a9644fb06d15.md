Calculation: Support/resistance = track the latest confirmed pivot low/high (using equal left/right pivot lookbacks); merge a new pivot into the existing level when its price is within the ATR zone measured at the pivot bar, updating the level to the touch-count-weighted average, otherwise reset the level and count to one. Count distinct bar touches when the bar’s range overlaps the level’s ATR zone and at least the touch-separation lookback bars have passed since the last counted touch. A level is valid when its touch count reaches the minimum signal count.
Calculation: ATR zone = ATR × zone-width parameter.
Calculation: At support/resistance = current bar range overlaps the respective level’s ATR zone.
Calculation: Bullish rejection = close > open AND lower wick ≥ body × rejection-ratio parameter AND lower wick > upper wick; body is max(|close − open|, minimum price tick).
Calculation: Bearish rejection = close < open AND upper wick ≥ body × rejection-ratio parameter AND upper wick > lower wick; body is max(|close − open|, minimum price tick).
Calculation: Bullish engulfing = close > open AND prior close < prior open AND open ≤ prior close AND close ≥ prior open.
Calculation: Bearish engulfing = close < open AND prior close > prior open AND open ≥ prior close AND close ≤ prior open.
Calculation: Support reclaim = valid support AND at support AND low < support − 0.2 × ATR zone AND close > support.
Calculation: Support entry = support reclaim OR (valid support AND at support AND bullish rejection) OR (valid support AND at support AND bullish engulfing).
Calculation: Resistance breakout = valid resistance AND close > resistance + 0.2 × ATR zone AND prior close ≤ resistance + 0.2 × ATR zone. Store its resistance level and touch count; until the retest lookback expires, a later bar retests when its range overlaps that stored level’s ATR zone and holds when close ≥ stored level.
Calculation: Resistance warning = (valid resistance AND at resistance AND bearish rejection) OR (valid resistance AND at resistance AND bearish engulfing) OR (valid resistance AND high > resistance + 0.2 × ATR zone AND close < resistance).
Calculation: Previous-period low = lowest low of the configured number of immediately preceding completed bars, excluding the current bar.
Long: Not in a trade AND no re-buy is armed AND cooldown since the prior long signal has elapsed AND (support entry OR a stored resistance breakout retest holds with bullish rejection or bullish engulfing).
Long: Not in a trade AND re-buy is armed and unused AND bar is after the exit and within the re-buy lookback AND close crosses above saved setup level + ATR × re-buy buffer (prior close ≤ threshold) AND (bullish rejection OR bullish engulfing OR close > open AND close > prior close).
Exit: Long, in a trade AND (before resistance-warning protection activates, a bar after entry closes below the previous-period low captured at entry; OR after protection activates, a later bar closes below the rolling previous-period low).
Short: 
