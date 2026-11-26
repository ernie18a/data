Calculation: Smoothed OBV = cumulative sum of volume when A > A[1], negative volume when A < A[1], and zero otherwise, where A is the mean of SMA(close, length 1), SMA(close, length 2), SMA(close, length 3), SMA(close, length 4), SMA(close, length 5), and SMA(close, length 6)
Calculation: OBV velocity = absolute value of Smoothed OBV minus Smoothed OBV[1]
Long: OBV velocity > SMA(OBV velocity, volume lookback) * deceleration multiplier AND OBV velocity >= SMA(OBV velocity, volume lookback) * acceleration multiplier AND Smoothed OBV > Smoothed OBV[1]
Short: OBV velocity > SMA(OBV velocity, volume lookback) * deceleration multiplier AND OBV velocity >= SMA(OBV velocity, volume lookback) * acceleration multiplier AND Smoothed OBV <= Smoothed OBV[1]
Long: OBV velocity > SMA(OBV velocity, volume lookback) * deceleration multiplier AND OBV velocity < SMA(OBV velocity, volume lookback) * acceleration multiplier AND Smoothed OBV > Smoothed OBV[1]
Short: OBV velocity > SMA(OBV velocity, volume lookback) * deceleration multiplier AND OBV velocity < SMA(OBV velocity, volume lookback) * acceleration multiplier AND Smoothed OBV <= Smoothed OBV[1]
Long: Smoothed OBV > SMA(Smoothed OBV, OBV SMA length)
Short: Smoothed OBV <= SMA(Smoothed OBV, OBV SMA length)
Long: Smoothed OBV crosses above SMA(Smoothed OBV, OBV SMA length)
Short: Smoothed OBV crosses below SMA(Smoothed OBV, OBV SMA length)