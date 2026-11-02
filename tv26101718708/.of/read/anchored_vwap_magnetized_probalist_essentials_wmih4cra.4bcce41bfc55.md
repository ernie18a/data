Calculation: Anchored VWAP and deviation = Starting with the first available bar, accumulate source × volume, volume, and source² × volume; reset all sums before processing each selected session, week, month, or custom-date anchor bar. Anchored VWAP is sum(source × volume) / sum(volume); deviation is sqrt(sum(source² × volume) / sum(volume) − anchored VWAP²). Source is a configurable price series. Both are undefined when cumulative volume is zero; deviation is also undefined when the variance is negative.
Calculation: Inner and outer bands = Anchored VWAP ± a configurable multiplier × deviation, using separate multipliers for the inner and outer bands.
Long: Close exceeds anchored VWAP.
Short: Close is below anchored VWAP.
Long: Close from a configurable number of bars ago is below the lower outer band from that same bar.
Short: Close from a configurable number of bars ago is above the upper outer band from that same bar.
Long: Close is at or above the lower outer band AND the previous close was below the previous lower outer band.
Short: Close is at or below the upper outer band AND the previous close was above the previous upper outer band.
Long: Close exceeds anchored VWAP AND the previous close was at or below the previous anchored VWAP.
Short: Close is below anchored VWAP AND the previous close was at or above the previous anchored VWAP.