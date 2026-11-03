Calculation: Composite = weighted combination of normalized Money Flow Index, percentile rank of daily-reset cumulative volume delta, and z-score of on-balance-volume rate of change; Hull-smoothed, scaled, and clamped.
Calculation: Bullish divergence zone = range between the lowest low and lowest candle-body low over the configured zone lookback, ending at the confirmed pivot low.
Calculation: Bearish divergence zone = range between the highest high and the highest candle-body high over the configured zone lookback, ending at the confirmed pivot high.
Long: Confirmed composite pivot low AND its price low < the previous confirmed price pivot low AND its composite value > the previous confirmed composite pivot low AND the pivots are within the configured divergence window [AND a recent bullish fair value gap if FVG confluence is enabled]
Long: Confirmed composite pivot low AND its price low > the previous confirmed price pivot low AND its composite value < the previous confirmed composite pivot low AND the pivots are within the configured divergence window [AND a recent bullish fair value gap if FVG confluence is enabled]
Long: Current bar overlaps an active bullish divergence zone AND close > open
Long: At least three active bullish divergence zones AND a fresh regular bullish divergence
Long: Composite > 0 for the configured consecutive-bar streak
Short: Confirmed composite pivot high AND its price high > the previous confirmed price pivot high AND its composite value < the previous confirmed composite pivot high AND the pivots are within the configured divergence window [AND a recent bearish fair value gap if FVG confluence is enabled]
Short: Confirmed composite pivot high AND its price high < the previous confirmed price pivot high AND its composite value > the previous confirmed composite pivot high AND the pivots are within the configured divergence window [AND a recent bearish fair value gap if FVG confluence is enabled]
Short: Current bar overlaps an active bearish divergence zone AND close < open
Short: At least three active bearish divergence zones AND a fresh regular bearish divergence
Short: Composite < 0 for the configured consecutive-bar streak