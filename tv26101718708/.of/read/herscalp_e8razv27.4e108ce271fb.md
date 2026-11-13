Calculation: EMA fast/mid/slow = exponential moving averages of close, with fast shorter than mid and mid shorter than slow
Calculation: VWAP = session-anchored (resets each day) volume-weighted average of (high+low+close)/3
Calculation: MACD hist = standard MACD line minus its signal line, on close
Calculation: ATR_entry = Wilder ATR on the chart timeframe, taken on the entry bar's close
Calculation: long_score = 2*[EMAfast>EMAmid AND EMAmid>EMAslow] + 2*[EMAfast crosses above EMAmid on this bar] + 2*[MACD hist>0 AND previous bar's MACD hist<=0] + 1*[close>VWAP] + 1*[RSI > a lower bound just below neutral AND RSI < an overbought bound] + 1*[EMAfast>EMAmid>EMAslow AND low is within +/- (a fraction of ATR) of EMAmid]
Calculation: short_score = mirror of long_score: 2*[EMAfast<EMAmid AND EMAmid<EMAslow] + 2*[EMAfast crosses below EMAmid on this bar] + 2*[MACD hist<0 AND previous bar's MACD hist>=0] + 1*[close<VWAP] + 1*[RSI < an upper bound just above neutral AND RSI > an oversold bound] + 1*[EMAfast<EMAmid<EMAslow AND high is within +/- (a fraction of ATR) of EMAmid]
Long: long_score >= min_score AND long_score > short_score AND NOT (on the previous bar, long_score >= min_score AND long_score > short_score); enter at close
Short: short_score >= min_score AND short_score > long_score AND NOT (on the previous bar, short_score >= min_score AND short_score > long_score); enter at close
Exit: long, low <= entry - stop_mult*ATR_entry (full stop)
Exit: short, high >= entry + stop_mult*ATR_entry (full stop)
Exit: long, high >= entry + k*ATR_entry for each of three increasing multipliers k (T1<T2<T3, with stop_mult smaller than T1); scale out in portions at each target in order
Exit: short, low <= entry - k*ATR_entry for each of three increasing multipliers k (T1<T2<T3); scale out in portions at each target in order