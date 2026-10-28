Calculation: Williams VIX Fix = (highest close over the lookback − current low) / highest close over the lookback × 100; its upper band is its moving average plus a volatility multiple of its standard deviation, and its range threshold is its rolling maximum times a fraction. A raw event occurs when the prior value was at or above either threshold and the current value is below both. A filtered event additionally requires current low > prior low, current close > prior high, current close > close at either the longer or shorter prior lookback, and current close > close one bar ago. It is armed if a filtered event occurred within the recent arm window, including the current bar.
Calculation: Efficiency ratio = absolute change in close over its lookback / sum of absolute one-bar close changes over that lookback (0 if the denominator is 0).
Calculation: Bollinger lower band = moving average of close − volatility multiple × standard deviation of close, using the same lookback and multiplier as the upper band.
Calculation: Three-bar close position = (close − lowest low over three bars) / (highest high over three bars − lowest low over three bars), or 0.5 if the range is 0.
Long: Williams VIX Fix filtered event on the chart bar.
Long: low <= Bollinger lower band AND close > Bollinger lower band.
Long: Williams VIX Fix armed AND ADX < its threshold AND efficiency ratio < its threshold, on a signal-timeframe bar (the current bar of each evaluated timeframe; signals are evaluated at bar close).
Short: close <= Bollinger lower band.
Short: prior three-bar close position >= its threshold AND current three-bar close position < its threshold.
Exit: long, high >= entry price × (1 + target percentage for the signal timeframe) OR low <= entry price × (1 − stop percentage for the signal timeframe) OR elapsed bars >= timeout length.
Exit: short, low <= entry price × (1 − target percentage) OR high >= entry price × (1 + stop percentage) OR elapsed bars >= timeout length.