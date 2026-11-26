Calculation: Ref = level in {prior T1 high, prior T1 low, prior T1 mid, T1 open, T2 open} with minimum abs(open - level), where prior T1 high and prior T1 low are the high and low of the last completed T1 bar, prior T1 mid = (prior T1 high + prior T1 low) / 2, and T1 open and T2 open are the opens of the T1 and T2 bars still forming, all on chart bars (T2 longer than T1)
Calculation: Enter(W) = chart is intraday AND datetime in session W AND NOT datetime in session W on previous bar
Calculation: Engaged = (Enter(W1) OR Enter(W2) OR Enter(W3)) AND abs(open - Ref) <= touch tolerance * ATR(high, low, close, ATR lookback) AND NOT Engaged on any of previous (evaluation bars - 1) bars
Calculation: Age = barssince(Engaged)
Calculation: Hi = highest(high, Age + 1)
Calculation: Lo = lowest(low, Age + 1)
Calculation: Up = (Hi + Lo) / 2 >= Ref[Age]
Calculation: Clip(x) = min(max(x, 0), 1)
Calculation: Score = round(min(max(w1 * Clip(Dom / (k1 * ATR[Age])) + w2 * Clip(Away / (k2 * ATR[Age])) + w3 * Clip(Wick / (k3 * ATR[Age])) - w4 * Clip(Opp / (k4 * ATR[Age])), 0), 100)), with Dom = Up ? Hi - Ref[Age] : Ref[Age] - Lo, Opp = Up ? Ref[Age] - Lo : Hi - Ref[Age], Away = Up ? close - Ref[Age] : Ref[Age] - close, Wick = Up ? highest(min(open, close) - low, Age + 1) : highest(high - max(open, close), Age + 1)
Long: Age <= evaluation bars - 2 AND Up
Long: Age = evaluation bars - 1 AND Up AND Score >= minimum score
Long: Age = evaluation bars - 1 AND Up AND Score >= minimum score AND close > Ref[Age] AND position side is flat
Short: Age <= evaluation bars - 2 AND NOT Up
Short: Age = evaluation bars - 1 AND NOT Up AND Score >= minimum score
Short: Age = evaluation bars - 1 AND NOT Up AND Score >= minimum score AND close < Ref[Age] AND position side is flat
Exit: long, low <= reference at entry OR high >= entry + abs(entry - reference at entry) OR bars since entry >= horizon bars
Exit: short, high >= reference at entry OR low <= entry - abs(entry - reference at entry) OR bars since entry >= horizon bars