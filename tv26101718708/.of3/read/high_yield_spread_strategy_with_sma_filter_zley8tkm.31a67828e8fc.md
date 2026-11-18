Long: selected direction is long AND close of the selected high-yield-spread or VIX series on T1 (current bar, sampled on chart bars) > threshold AND (SMA filter is disabled OR chart close > SMA(chart close, lookback))
Short: selected direction is short AND close of the selected high-yield-spread or VIX series on T1 (current bar, sampled on chart bars) < threshold AND (SMA filter is disabled OR chart close < SMA(chart close, lookback))
Exit: long, chart bars since entry >= holding-period parameter
Exit: short, chart bars since entry >= holding-period parameter