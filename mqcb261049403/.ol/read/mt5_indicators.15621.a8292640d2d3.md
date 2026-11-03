Calculation: Upper band = smoothed moving average of bar highs plus a price-range offset; when one-way movement is enabled and prior channel direction is down, cap it at its previous value.
Calculation: Lower band = smoothed moving average of bar lows plus a price-range offset; when one-way movement is enabled and prior channel direction is up, floor it at its previous value. Both averages use the same smoothing method and lookback.
Calculation: Channel direction = initialize neutral; each bar set up if high > upper band, else set down if low < lower band, otherwise retain the prior direction.
Long: Prior channel direction <= neutral AND high > upper band
Short: Prior channel direction >= neutral AND high <= upper band AND low < lower band