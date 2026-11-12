Calculation: Open_k (k=1..4) = open of the still-forming bar (current bar's open, known in real time) at four ascending timeframes TF1<TF2<TF3<TF4; TF1 is the chart timeframe or a fixed lower timeframe if the chart timeframe is below it, and TF2..TF4 are all higher than the chart timeframe
Calculation: Score = sum over k=1..4 of (+1 if close >= Open_k else -1), range -4..+4
Calculation: Strong = abs(close - Open_2) / Open_2 * 100 >= minimum strength
Calculation: Spread = (max(Open_2,Open_3,Open_4) - min(Open_2,Open_3,Open_4)) / min(Open_2,Open_3,Open_4) * 100 >= minimum spread (minimum may be 0, i.e. no filter)
Calculation: Confirmed(cond) = cond true on N consecutive bars including the current bar (N is a debounce count)
Calculation: Cooldown = within K bars after the most recent losing exit (long exit with close < entry price, or short exit with close > entry price); the exit bar itself is not blocked
Long: Confirmed(Score >= long-entry threshold AND Strong AND Spread) AND NOT Cooldown AND (position is flat OR (position is short AND Exit-short condition is met, i.e. stop-and-reverse))
Short: shorts enabled AND Confirmed(Score <= short-entry threshold AND (optional gate: close < Open_4) AND Strong AND Spread) AND NOT Cooldown AND (position is flat OR (position is long AND Exit-long condition is met, i.e. stop-and-reverse)); the short-entry threshold is below the long-entry threshold
Exit: long, Confirmed(Score <= long-exit threshold), where the long-exit threshold is below the long-entry threshold
Exit: short, Confirmed(Score >= short-cover threshold), where the short-cover threshold is above the short-entry threshold