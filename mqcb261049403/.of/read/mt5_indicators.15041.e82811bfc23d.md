Calculation: HMA = Hull moving average of the selected price series; use chart bars or higher-timeframe bars. For higher-timeframe bars, calculate from the bar still forming at the end of the first chart bar in each higher-timeframe interval and hold that result through the rest of the interval.
Calculation: Change = current HMA minus previous HMA on the same timeframe.
Calculation: Deviation = population standard deviation of Change over a lookback including the current bar, calculated on the same timeframe as HMA.
Calculation: Rounded change and thresholds = round Change and each of two deviation multipliers times Deviation separately to the price precision plus two decimal places; the second multiplier is larger than the first.
Long: HMA > previous HMA on the same timeframe
Short: HMA < previous HMA on the same timeframe
Long: (rounded change > first rounded threshold AND rounded change <= second rounded threshold) OR rounded change > second rounded threshold
Short: (rounded change < negative first rounded threshold AND rounded change >= negative second rounded threshold) OR rounded change < negative second rounded threshold