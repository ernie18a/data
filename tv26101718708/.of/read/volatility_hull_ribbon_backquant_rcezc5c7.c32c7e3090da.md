Calculation: TRW(x, p) = sum over i=0..p of (x[i] * TR[i] * (p+1-i)) / sum over i=0..p of (TR[i] * (p+1-i)), where x[i] is x from i bars ago and TR = true range = max(high-low, |high-previous close|, |low-previous close|); all on chart timeframe bars
Calculation: H = TRW(2*TRW(close, p_short) - TRW(close, p_long), p_smooth), where p_short = p_long/2 (shorter lookback), p_smooth = round(sqrt(p_long)) (shortest lookback)
Long: H > H[1] AND H[1] <= H[2]
Short: H < H[1] AND H[1] >= H[2]