Calculation: pivot point = Classic pivot point(T1, last completed bar)
Calculation: upper entry level = pivot point + P1
Calculation: lower entry level = pivot point - P1
Calculation: extended lower level = pivot point - P2, P2 = 2 × P1
Calculation: T1 range = high(T1, last completed bar) - low(T1, last completed bar)
Calculation: long target = max(close(T1, last completed bar) + T1 range × P3, extended lower level - P4)
Calculation: short target = min(close(T1, last completed bar) - T1 range × P3, extended lower level - P4)
Calculation: long stop = max(lower entry level, highest(close[1] - P5 over bars since entry, where P5 > 0 AND close[1] - P5 > entry price))
Calculation: short stop = min(upper entry level, lowest(close[1] + P5 over bars since entry, where P5 > 0 AND close[1] + P5 < entry price))
Long: hour(datetime) >= session start hour AND hour(datetime) <= session end hour AND position side is flat AND close[1] < upper entry level AND close >= upper entry level
Short: hour(datetime) >= session start hour AND hour(datetime) <= session end hour AND position side is flat AND close[1] > lower entry level AND close <= lower entry level
Exit: long, hour(datetime) < session start hour OR hour(datetime) > session end hour OR low <= long stop OR high >= long target
Exit: short, hour(datetime) < session start hour OR hour(datetime) > session end hour OR high >= short stop OR low <= short target