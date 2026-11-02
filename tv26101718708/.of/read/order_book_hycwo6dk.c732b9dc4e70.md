Calculation: Buy volume = sum of volume from lower-timeframe bars within the current chart bar whose close >= open; use all available lower-timeframe bars, including the forming bar. If none are available, use chart-bar volume when close >= open, otherwise 0.
Calculation: Sell volume = sum of volume from lower-timeframe bars within the current chart bar whose close < open; use all available lower-timeframe bars, including the forming bar. If none are available, use chart-bar volume when close < open, otherwise 0.
Calculation: Cumulative delta = cumulative sum of buy volume minus sell volume from the start of the data.
Calculation: Pressure = clamp to [-1, 1] a positive factor times (0.62 × (buy volume - sell volume) / max(buy volume + sell volume, 1) + 0.23 × (2 × (close - low) / (high - low) - 1) + 0.15 × (close - open) / (high - low)); when high = low, use -1 for the close-position term and 0 for the body term.
Calculation: Profile-bin buy and sell volumes = divide the range from the lowest low to the highest high over a lookback into equal price bins; distribute each bar's buy and sell volumes equally among all bins touched by its low-to-high range, then sum each side per bin.
Long: buy volume >= sell volume
Short: sell volume > buy volume
Long: buy volume > sell volume × strong-volume ratio
Short: sell volume > buy volume × strong-volume ratio
Long: cumulative delta >= 0
Short: cumulative delta < 0
Long: pressure > positive pressure threshold
Short: pressure < negative pressure threshold
Long: profile-bin buy volume >= profile-bin sell volume AND profile-bin total volume > 0
Short: profile-bin sell volume > profile-bin buy volume AND profile-bin total volume > 0