Calculation: Candle Momentum Index = 100 × the third-stage smoothed candle momentum ÷ the third-stage smoothed absolute candle momentum (0 if the denominator is 0). Candle momentum is close minus open from XLength bars earlier; smooth it and its absolute value in parallel with the same configurable smoother, using three successive stages with long, intermediate, and short lookbacks. Use higher-timeframe bars; evaluate only completed bars.
Long: CMI[t-2] > CMI[t-1] AND CMI[t-1] < CMI[t]
Short: CMI[t-2] < CMI[t-1] AND CMI[t-1] > CMI[t]
Exit: long, CMI[t-1] > CMI[t]
Exit: short, CMI[t-1] < CMI[t]