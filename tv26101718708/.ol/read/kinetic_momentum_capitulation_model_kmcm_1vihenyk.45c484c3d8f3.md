Calculation: Volatility ratio = average true range divided by its simple moving average over a longer lookback
Calculation: Velocity lookback = a rounded constant divided by the volatility ratio, clamped to its configured minimum and maximum
Calculation: Volume lookback = a rounded constant divided by the volatility ratio, clamped to its configured minimum and maximum
Calculation: Velocity = close rate of change over the velocity lookback
Calculation: Relative volume mass = volume divided by its simple moving average over the volume lookback
Calculation: Directional energy = 0.5 × relative volume mass × velocity², positive when velocity is nonnegative and negative otherwise
Calculation: Standardized energy = (directional energy − its simple moving average over the volume lookback) divided by its standard deviation over the volume lookback
Calculation: KMCM = exponential moving average of 100 × tanh(standardized energy)
Calculation: KMCM slope = current KMCM minus prior-bar KMCM
Long: KMCM > upper threshold AND KMCM slope > 0
Short: KMCM < lower threshold AND KMCM slope < 0