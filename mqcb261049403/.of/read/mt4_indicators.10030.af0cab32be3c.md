Calculation: Channel midpoint = (highest high + lowest low) / 2 over the same lookback including the current bar.
Calculation: EMA slope = 10000 × (median-price EMA at the more recent offset − median-price EMA at the older offset) / (older offset − more recent offset), using the same EMA period for both.
Calculation: Midpoint state = the direction of the most recent bar whose close differs from its channel midpoint: long if above, short if below; initially neither. Evaluate each decision before updating this state with the current bar.
Long: Current high > highest high over the channel lookback ending on the previous bar AND EMA slope > positive threshold.
Short: Current low < lowest low over the channel lookback ending on the previous bar AND EMA slope < negative of the same threshold.
Long: Close > channel midpoint AND midpoint state is not long.
Short: Close < channel midpoint AND midpoint state is not short.