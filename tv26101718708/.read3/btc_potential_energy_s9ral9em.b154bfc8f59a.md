Calculation: Deviation = EMA(close, smoothing length) - SMA(EMA(close, smoothing length), baseline lookback)
Calculation: Potential Energy = 100 × count(Deviation > Deviation[n], n=1..percentile lookback) / percentile lookback
Long: Potential Energy >= charge threshold AND Deviation[k] < Deviation[k+1] for every k=0..decline lookback-1 AND NOT (Potential Energy[1] >= charge threshold AND Deviation[k] < Deviation[k+1] for every k=1..decline lookback)
Calculation: USDT dominance deviation = EMA(USDT dominance, deviation smoothing length) − SMA(EMA(USDT dominance, deviation smoothing length), baseline length)
Calculation: Potential Energy = 100 × count of prior USDT dominance deviations below the current deviation in the percentile lookback ÷ percentile lookback
Long: Potential Energy ≥ charge threshold AND USDT dominance deviation has fallen for consecutive bars
Long: EMA(Potential Energy, smoothing length) crosses below charge threshold