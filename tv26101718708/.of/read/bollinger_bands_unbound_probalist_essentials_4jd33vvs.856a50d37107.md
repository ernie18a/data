Calculation: Bollinger basis = configured moving average of close; upper/lower bands = basis ± configured multiplier × standard deviation of close over the same lookback
Calculation: Bandwidth = (upper band − lower band) / basis × 100
Long: after the configured confirmation delay, the completed bar confirms a close back above the lower band but below the upper band, following a prior close below the lower band; if the RSI filter is enabled, RSI on the excursion bar is at or below its oversold threshold; the signal is at least the configured spacing from the previous long fade
Short: after the configured confirmation delay, the completed bar confirms a close back below the upper band but above the lower band, following a prior close above the upper band; if the RSI filter is enabled, RSI on the excursion bar is at or above its overbought threshold; the signal is at least the configured spacing from the previous short fade
Long: on a completed bar, close is above the upper band and the preceding completed bar was within or on both bands (upper-band walk start)
Short: on a completed bar, close is below the lower band and the preceding completed bar was within or on both bands (lower-band walk start)
Long: bandwidth rises above its rolling percentile after being at or below it, and the completed bar closes above the upper band
Short: bandwidth rises above its rolling percentile after being at or below it, and the completed bar closes below the lower band
Exit: long, high reaches or exceeds the Bollinger basis
Exit: short, low reaches or falls below the Bollinger basis