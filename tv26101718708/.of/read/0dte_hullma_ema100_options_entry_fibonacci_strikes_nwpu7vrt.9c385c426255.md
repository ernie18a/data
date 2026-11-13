Calculation: HullMA = Hull moving average of close
Calculation: EMA = exponential moving average of close, on the chart timeframe
Calculation: HullUp = HullMA > HullMA of the previous bar
Calculation: FlipGreen = HullUp is false on the previous bar AND HullUp is true on the current bar
Calculation: FlipRed = HullUp is true on the previous bar AND HullUp is false on the current bar
Calculation: BarsSinceFlip = number of bars since the most recent FlipGreen (or FlipRed); 0 on the flip bar
Calculation: BarsFromOpen = number of bars since the first bar of the current day; 0 on the first bar
Long: (BarsSinceFlip of FlipGreen <= wait window) AND close > EMA AND BarsFromOpen >= skip-open count AND this same three-part condition was false on the previous bar AND bars since the last Long or Short signal > cooldown
Short: (BarsSinceFlip of FlipRed <= wait window) AND close < EMA AND BarsFromOpen >= skip-open count AND this same three-part condition was false on the previous bar AND bars since the last Long or Short signal > cooldown