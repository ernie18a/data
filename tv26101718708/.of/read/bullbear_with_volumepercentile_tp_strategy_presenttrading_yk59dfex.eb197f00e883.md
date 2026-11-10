Calculation: Bull Bear Power = high + low - 2 × EMA(close).
Calculation: Bull Bear Power Z-score = (Bull Bear Power - SMA(Bull Bear Power)) / standard deviation of Bull Bear Power over the same lookback.
Calculation: Price rank = 100 × the percentage of closes in the percentile lookback that are less than or equal to the oldest close in that lookback, including the current close.
Calculation: Take-profit factor = average of the volume score and price score. Volume score is the high, medium, or low volume factor when volume / SMA(volume) exceeds the corresponding high, medium, or low threshold, checked in that order; otherwise it is the fallback factor. Price score uses the same ordered rule with price rank, percentile thresholds, percentile factors, and the fallback factor.
Calculation: Take-profit distance = ATR × take-profit factor × a target multiplier; use three target multipliers ordered from smaller to larger and a separate position percentage for each.
Long: Bull Bear Power Z-score crosses above the positive entry threshold.
Long: Bull Bear Power >= 0.
Short: Bull Bear Power Z-score crosses below the negative entry threshold, whose magnitude equals the positive entry threshold.
Short: Bull Bear Power < 0.
Exit: long, Bull Bear Power Z-score crosses below 0.
Exit: short, Bull Bear Power Z-score crosses above 0.
Exit: long, take profit is enabled AND high >= entry price + take-profit distance calculated on the previous completed bar; exit the target's position percentage at each of the three targets.
Exit: short, take profit is enabled AND low <= entry price - take-profit distance calculated on the previous completed bar; exit the target's position percentage at each of the three targets.