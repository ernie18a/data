Calculation: Fast line = SMA(close, shorter lookback) − SMA(close, longer lookback)
Calculation: Slow line = SMA(Fast line, longer lookback)
Calculation: Upper/lower band = ± multiplier × standard deviation of Fast line over a lookback
Calculation: Confirmed Fast-line pivot high/low = a high/low greater/less than the specified number of bars on both sides; confirmed after the right-side bars complete
Long: Slow line crosses above 0
Long: Slow line > 0 AND Fast line crosses above Slow line AND this is the first such cross since Slow line last crossed above 0 AND (higher-timeframe Slow line > 0 if the higher-timeframe filter is enabled; use the higher timeframe’s still-forming bar)
Long: Slow line > its prior value AND Fast line > its prior value AND Fast line decreased for at least the specified number of consecutive prior bars AND (higher-timeframe Slow line > 0 if the higher-timeframe filter is enabled; use the higher timeframe’s still-forming bar)
Long: Prior Fast line < prior lower band AND current Fast line > prior Fast line
Long: At a confirmed Fast-line pivot low, pivot low Fast line > prior confirmed pivot low Fast line AND pivot low price < prior pivot low price AND bars between the pivot lows are within the specified minimum and maximum
Short: Slow line crosses below 0
Short: Slow line < 0 AND Fast line crosses below Slow line AND this is the first such cross since Slow line last crossed below 0 AND (higher-timeframe Slow line < 0 if the higher-timeframe filter is enabled; use the higher timeframe’s still-forming bar)
Short: Slow line < its prior value AND Fast line < its prior value AND Fast line increased for at least the specified number of consecutive prior bars AND (higher-timeframe Slow line < 0 if the higher-timeframe filter is enabled; use the higher timeframe’s still-forming bar)
Short: Prior Fast line > prior upper band AND current Fast line < prior Fast line
Short: At a confirmed Fast-line pivot high, pivot high Fast line < prior confirmed pivot high Fast line AND pivot high price > prior pivot high price AND bars between the pivot highs are within the specified minimum and maximum