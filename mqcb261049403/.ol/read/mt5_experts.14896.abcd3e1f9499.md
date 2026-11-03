Calculation: Short-term line = apply a moving-average smoothing to the configured applied price, then smooth that result again using a shorter lookback than the long-term line.
Calculation: Long-term line = apply a moving-average smoothing to the configured applied price, then smooth that result again using a longer lookback than the short-term line.
Long: On the configured indicator timeframe, the last completed bar has short-term line <= long-term line AND the preceding completed bar has short-term line > long-term line.
Short: On the configured indicator timeframe, the last completed bar has short-term line >= long-term line AND the preceding completed bar has short-term line < long-term line.
Exit: Long, on the preceding completed bar of the configured indicator timeframe, short-term line < long-term line.
Exit: Short, on the preceding completed bar of the configured indicator timeframe, short-term line > long-term line.