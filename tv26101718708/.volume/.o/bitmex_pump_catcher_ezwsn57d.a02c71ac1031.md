Calculation: normalized volume = current rolling volume sum divided by the average of earlier, non-overlapping rolling volume sums sampled over a longer history
Long: normalized volume > its threshold AND prior-bar normalized volume <= its threshold AND close > close from an earlier bar AND slow EMA of normalized volume > its prior-bar value
Short: normalized volume > its threshold AND prior-bar normalized volume <= its threshold AND close < close from an earlier bar AND slow EMA of normalized volume > its prior-bar value
Exit: Long, slow EMA of normalized volume > fast EMA of normalized volume
Exit: Short, slow EMA of normalized volume > fast EMA of normalized volume