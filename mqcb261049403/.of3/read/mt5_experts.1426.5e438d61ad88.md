Calculation: STC[n] = Schaff Trend Cycle(close, fast lookback, slow lookback, cycle lookback) on the nth completed T1 bar ago, where n=0 is the last completed bar
Long: STC[0] > upper threshold AND STC[1] > upper threshold AND STC[1] >= STC[2]
Short: STC[1] < lower threshold AND STC[0] >= lower threshold
Exit: long, STC[1] < lower threshold
Exit: short, STC[1] > upper threshold AND STC[1] >= STC[2]