Calculation: trend score = average across T1–T10 of +1 when EMA(close, shorter lookback, Tn) > EMA(close, longer lookback, Tn), otherwise −1; evaluated on chart bars using each Tn’s latest available value (the last completed bar historically and the still-forming bar in real time)
Long: trend score >= strength threshold AND trend score[1] < strength threshold
Short: trend score <= −strength threshold AND trend score[1] > −strength threshold
Exit: long, high >= entry price * (1 + take-profit percent / 100) OR low <= entry price * (1 − stop-loss percent / 100)
Exit: short, low <= entry price * (1 − take-profit percent / 100) OR high >= entry price * (1 + stop-loss percent / 100)