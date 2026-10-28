Calculation: Efficiency = absolute(close − open) / volume
Calculation: Efficiency z-score = (Efficiency − its rolling mean) / its rolling standard deviation
Calculation: Volume z-score = (volume − its rolling mean) / its rolling standard deviation
Calculation: Center of Gravity = Wilder-smoothed(close × volume) / Wilder-smoothed(volume)
Long: Efficiency z-score > sensitivity threshold AND close > open AND (filter is All OR filter is Preferred AND (high + low) / 2 < Center of Gravity OR filter is Distal AND (high + low) / 2 > Center of Gravity) OR Volume z-score > sensitivity threshold AND close < open
Short: Efficiency z-score > sensitivity threshold AND close < open AND (filter is All OR filter is Preferred AND (high + low) / 2 > Center of Gravity OR filter is Distal AND (high + low) / 2 < Center of Gravity) OR Volume z-score > sensitivity threshold AND close > open