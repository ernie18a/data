Calculation: positive line = XMA(100 × (max(high − high[1], 0) if max(high − high[1], 0) > max(low[1] − low, 0), otherwise 0) / True Range(high, low, close[1]), smoothing method, phase, lookback), or 0 when True Range = 0
Calculation: negative line = XMA(100 × (max(low[1] − low, 0) if max(low[1] − low, 0) > max(high − high[1], 0), otherwise 0) / True Range(high, low, close[1]), same smoothing method, phase, and lookback), or 0 when True Range = 0
Long: positive line > negative line
Short: negative line > positive line