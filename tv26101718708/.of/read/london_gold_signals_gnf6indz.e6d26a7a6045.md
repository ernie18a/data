Calculation: ATR = average true range over a fixed lookback on the chart timeframe; the exit levels use the ATR value on the entry bar
Calculation: VWAP = volume-weighted average price of typical price (high+low+close)/3, anchored to the session and reset each day
Calculation: PrevAsiaHigh / PrevAsiaLow = highest high / lowest low of the overnight Asia session that came before the most recently started Asia session; the value updates only when a new Asia session starts and is empty until two Asia sessions exist
Calculation: NewsHigh / NewsLow = high / low of the chart-timeframe bar that opens at the 8:30 ET news time; held until the next day's 8:30 bar replaces it; empty before the first one
Calculation: Vote counts. Each of three votes is +1 (long), -1 (short) or 0. Range vote = +1 if close > PrevAsiaHigh, -1 if close < PrevAsiaLow, else 0. VWAP vote = +1 if close > VWAP, else -1. News vote = -1 if |close - NewsHigh| <= f*ATR, else +1 if |close - NewsLow| <= f*ATR, else 0, where f is a fraction below 1 (near the news high is a short vote and takes priority over near the news low). LongVotes = number of votes equal to +1. ShortVotes = number of votes equal to -1.
Long: LongVotes > ShortVotes (evaluated on every bar, with no session-time restriction)
Short: ShortVotes > LongVotes (evaluated on every bar, with no session-time restriction)
Exit: long, low <= entry - s*ATR OR high >= entry + t*ATR
Exit: short, high >= entry + s*ATR OR low <= entry - t*ATR
Note: s is the stop multiple. The targets are three multiples t1 < t2 < t3 (quick scalp, main target, runner), and s equals t1. Exit at t2 if a single target is used, or scale out across the three.