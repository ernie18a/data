Calculation: delta = upVol - dnVol, where upVol = volume if ((close - low) > (high - close) OR close > open) else 0, and dnVol = volume if ((close - low) < (high - close) OR close < open) else 0
Calculation: osc = EMA of delta
Calculation: sig = SMA of osc
Long: osc crosses above sig (previous osc <= previous sig AND current osc > current sig) AND osc < 0
Short: osc crosses below sig (previous osc >= previous sig AND current osc < current sig) AND osc > 0