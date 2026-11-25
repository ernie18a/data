Calculation: weighted line(x, lookback, weight base, offset) = (sum[k=1..lookback](x[k-1]) + (sum[k=1..lookback](k^2) - 2*sum[k=1..lookback](x[k-1]*(weight base-k)))*offset/sum[k=1..lookback](k))/sum[k=1..lookback](k)
Calculation: coefficient = orientation*ln(weighted line(hl2, lookback, weight base, offset)/weighted line(SMMA(close, lookback), lookback, weight base, offset)), computed on T1 bars using the current forming T1 bar and projected to chart bars
Long: coefficient > 0
Short: coefficient < 0