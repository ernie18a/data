Long: low > EMA(typical, long-entry lookback)
Short: high < SMA(open, short-entry lookback)
Exit: long, on chart bars using T1 values, close(T1, current forming bar) < SMMA(typical, long-term lookback, T1, current forming bar, MA line shift) AND close(T1, last completed bar) > SMMA(typical, long-term lookback, T1, last completed bar, MA line shift)
Exit: short, on chart bars using T1 values, close(T1, current forming bar) > SMMA(typical, long-term lookback, T1, current forming bar, MA line shift) AND close(T1, last completed bar) < SMMA(typical, long-term lookback, T1, last completed bar, MA line shift)
Exit: long, high >= entry price + long take-profit distance
Exit: short, low <= entry price - short take-profit distance
Exit: long, highest high since entry - entry price > long trailing distance AND low <= highest high since entry - long trailing distance
Exit: short, entry price - lowest low since entry > short trailing distance AND high >= lowest low since entry + short trailing distance