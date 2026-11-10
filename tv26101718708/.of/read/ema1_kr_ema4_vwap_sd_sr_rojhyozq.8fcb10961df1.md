Calculation: Kernel regression = weighted mean of the current close and closes over a lookback, with weight exp(-i² / (2 × (lookback / 2)²)) for the close i bars ago; before the lookback is available, use the current close.
Calculation: Estimated buying volume = volume × (close - low) / (high - low), or volume / 2 when high equals low.
Calculation: Estimated selling volume = volume - estimated buying volume.
Long: Short-term EMA of close > kernel regression.
Short: Short-term EMA of close <= kernel regression.
Long: Short-term EMA of close crosses above kernel regression.
Short: Short-term EMA of close crosses below kernel regression.
Long: Close < close a specified number of bars earlier for exactly a specified consecutive count of bars.
Short: Close > close the same number of bars earlier for exactly the same consecutive count of bars.
Long: Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi close crosses above the maximum of the short-term EMA of close and kernel regression.
Long: Close > long-term EMA of close.
Short: Close <= long-term EMA of close.
Long: Close > short-term EMA of close.
Short: Close <= short-term EMA of close.
Long: Latest confirmed pivot low > previous confirmed pivot low.
Short: Latest confirmed pivot low <= previous confirmed pivot low.
Long: Close > session VWAP of typical price.
Short: Close <= session VWAP of typical price.
Long: Estimated buying volume > estimated selling volume.
Short: Estimated buying volume <= estimated selling volume.