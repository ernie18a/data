Calculation: Body = abs(open - close)
Calculation: Range = high - low
Calculation: Lower wick = min(open, close) - low
Calculation: Upper wick = high - max(open, close)
Long: low <= low[1] AND Range > 0 AND Body > 0 AND Body <= body threshold * Range AND Lower wick >= dominant wick multiplier * Body AND Upper wick <= opposite wick limit * Body AND (volume filter disabled OR volume >= SMA(volume, volume lookback) * volume multiplier)
Short: high >= high[1] AND Range > 0 AND Body > 0 AND Body <= body threshold * Range AND Upper wick >= dominant wick multiplier * Body AND Lower wick <= opposite wick limit * Body AND (volume filter disabled OR volume >= SMA(volume, volume lookback) * volume multiplier)