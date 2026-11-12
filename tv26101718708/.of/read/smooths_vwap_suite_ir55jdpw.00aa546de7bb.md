Calculation: DVWAP = cumulative sum(hlc3*volume)/cumulative sum(volume), reset at the start of each trading day (day-session anchor)
Calculation: WVWAP = cumulative sum(hlc3*volume)/cumulative sum(volume), reset at the start of each trading week
Calculation: SD = sqrt(max(cumulative sum(hlc3^2*volume)/cumulative sum(volume) - DVWAP^2, 0)), same daily reset as DVWAP
Calculation: Lower1 = DVWAP - m1*SD; Lower2 = DVWAP - m2*SD; Upper1 = DVWAP + m1*SD; Upper2 = DVWAP + m2*SD (m1 < m2)
Calculation: EMA = exponential moving average of close; rising = EMA > EMA of previous bar; falling = EMA < EMA of previous bar
Long: bars since the last Long or Short signal (either direction) > cooldown AND EMA rising AND ((high > DVWAP AND low < DVWAP AND close > DVWAP AND close > WVWAP) OR (close > DVWAP AND close > open AND ((low <= Lower1 AND close > Lower1) OR (low <= Lower2 AND close > Lower2))))
Short: bars since the last Long or Short signal (either direction) > cooldown AND EMA falling AND ((high > DVWAP AND low < DVWAP AND close < DVWAP AND close < WVWAP) OR (close < DVWAP AND close < open AND ((high >= Upper1 AND close < Upper1) OR (high >= Upper2 AND close < Upper2))))