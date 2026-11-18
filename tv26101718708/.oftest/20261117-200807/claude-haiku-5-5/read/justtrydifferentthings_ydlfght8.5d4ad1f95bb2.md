Calculation: HighLevel = ema(highest(open of the last completed bar of timeframe T, W), E)
Calculation: LowLevel = ema(lowest(open of the last completed bar of timeframe T, W), E)
Long: crossunder(sma(HighLevel, S), sma(HighLevel, G)) AND G > S
Short: crossover(sma(LowLevel, S), sma(LowLevel, G)) AND G > S