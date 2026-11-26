Calculation: New source bar = change(selected source bar time_close) != 0; evaluate on chart bars using chart-timeframe bars when multi-timeframe scanning is disabled, or T1 values with lookahead off when enabled (last completed T1 bar historically, still-forming T1 bar in realtime)
Long: standard detection enabled AND New source bar AND high[1] < low[3] AND close > low[3]
Short: standard detection enabled AND New source bar AND low[1] > high[3] AND close < high[3]
Long: extended detection enabled AND New source bar AND high[2] < low[4] AND close[1] <= high[2] AND close > low[4]
Short: extended detection enabled AND New source bar AND low[2] > high[4] AND close[1] >= low[2] AND close < high[4]