Calculation: Mid = (highest + lowest completed T1 close within the range window) / 2, per session, where a session is one range window followed by its extension window
Calculation: Range = highest - lowest completed T1 close within the range window, or when normalization is enabled, the average of that quantity over the last normalization lookback completed sessions
Calculation: Deviation = (close - Mid) / Range, where close is the forming chart bar's close
Calculation: Tag(side, L, s) = some completed T1 bar in session s's extension window has high >= Mid + (0.5 + L) * Range for side upper, or low <= Mid - (0.5 + L) * Range for side lower; L is a deviation level; Mid and Range are session s's
Calculation: Reach(side) = the highest deviation level L with Tag(side, L, most recent session), undefined if none
Calculation: Reverted(s) = some completed T1 bar in session s's extension window, at or after the first bar on which any level is tagged in s, has low <= Mid <= high
Calculation: Touches(side, L) = number of the last stats lookback completed sessions s with Tag(side, L, s)
Calculation: RevertRate(side, L) = round(100 * number of the last stats lookback completed sessions s with Tag(side, L, s) and Reverted(s) / Touches(side, L))
Calculation: Stop(upper) = Mid + (0.5 + Next(upper)) * Range; Stop(lower) = Mid - (0.5 + Next(lower)) * Range; Next(side) = the next higher deviation level after Reach(side), or the top deviation level plus a top-level buffer when Reach(side) is the top deviation level
Calculation: GapLevel = close of the most recent completed T1 bar at gap time
Calculation: Filled = some completed T1 bar after the most recent gap-time bar and within the fill window has low <= GapLevel <= high
Calculation: GapCount = number of the last stats lookback gaps set before the most recent gap-time bar
Calculation: GapFills = number of the last stats lookback gaps set before the most recent gap-time bar that were filled before the next gap-time bar
Calculation: Remaining = minutes from the current bar time to the end of the extension window of the most recent session, or no limit outside that window
Calculation: AboveShare = round(100 * number of the last stats lookback completed sessions whose last completed T1 close in the extension window is above their Mid / number of those sessions)
Long: Deviation <= -tolerance * Reach(lower) AND Touches(lower, Reach(lower)) >= min touches AND RevertRate(lower, Reach(lower)) >= revert threshold AND Remaining >= min remaining minutes AND NOT (NOT Filled AND close > GapLevel AND GapCount >= min gaps AND GapFills * 100 >= revert threshold * GapCount)
Short: Deviation >= tolerance * Reach(upper) AND Touches(upper, Reach(upper)) >= min touches AND RevertRate(upper, Reach(upper)) >= revert threshold AND Remaining >= min remaining minutes AND NOT (NOT Filled AND close < GapLevel AND GapCount >= min gaps AND GapFills * 100 >= revert threshold * GapCount)
Long: NOT Filled AND close < GapLevel
Short: NOT Filled AND close > GapLevel
Long: NOT Filled AND Mid < close AND close < GapLevel AND GapCount >= min gaps AND GapFills * 100 >= revert threshold * GapCount AND Remaining >= min remaining minutes
Short: NOT Filled AND GapLevel < close AND close < Mid AND GapCount >= min gaps AND GapFills * 100 >= revert threshold * GapCount AND Remaining >= min remaining minutes
Long: AboveShare >= up-bias threshold
Short: AboveShare <= down-bias threshold
Exit: long, entry price < Mid AND close >= Mid
Exit: long, entry price < Mid AND close <= Stop(lower)
Exit: long, GapLevel > entry price AND Filled becomes true
Exit: short, entry price > Mid AND close <= Mid
Exit: short, entry price > Mid AND close >= Stop(upper)
Exit: short, GapLevel < entry price AND Filled becomes true