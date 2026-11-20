Calculation: USDT dominance deviation = EMA(USDT dominance, deviation smoothing length) − SMA(EMA(USDT dominance, deviation smoothing length), baseline length)
Calculation: Potential Energy = 100 × count of prior USDT dominance deviations below the current deviation in the percentile lookback ÷ percentile lookback
Long: Potential Energy ≥ charge threshold AND USDT dominance deviation has fallen for consecutive bars
Long: EMA(Potential Energy, smoothing length) crosses below charge threshold