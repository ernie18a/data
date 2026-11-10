Calculation: Valid OBV = cumulative on-balance volume when current volume is nonzero; otherwise undefined.
Calculation: OBV momentum = change in valid OBV over the volume analysis lookback divided by that lookback.
Calculation: Smoothed OBV momentum = least-squares moving average of golden ratio times OBV momentum divided by the simple moving average of volume over the volume analysis lookback.
Calculation: OBV momentum acceleration = golden ratio times the change in OBV momentum over the volume analysis lookback divided by that lookback and by the simple moving average of volume over the same lookback.
Calculation: Confirmed oscillator pivot = pivot high or low of smoothed OBV momentum using left and right lookbacks, identified on the bar after the specified number of right-hand bars has completed. Compare its oscillator value and the high or low of its pivot bar with those of the previous confirmed pivot of the same type. The number of bars between their confirmation bars minus one must be within the inclusive pivot range.
Long: volume > 0 AND close >= open
Short: volume > 0 AND close < open
Long: smoothed OBV momentum > 0 AND OBV momentum acceleration is defined
Short: smoothed OBV momentum <= 0 AND OBV momentum acceleration is defined
Long: confirmed oscillator pivot low AND current pivot oscillator > previous pivot oscillator AND current pivot-bar low < previous pivot-bar low
Long: confirmed oscillator pivot low AND current pivot oscillator < previous pivot oscillator AND current pivot-bar low > previous pivot-bar low
Short: confirmed oscillator pivot high AND current pivot oscillator < previous pivot oscillator AND current pivot-bar high > previous pivot-bar high
Short: confirmed oscillator pivot high AND current pivot oscillator > previous pivot oscillator AND current pivot-bar high < previous pivot-bar high