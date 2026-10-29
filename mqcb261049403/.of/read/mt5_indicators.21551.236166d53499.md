Calculation: Volume Zone Oscillator (VZO) = 100 × the exponentially smoothed signed volume divided by the exponentially smoothed total volume; signed volume is current volume when close > previous close, negative current volume when close < previous close, and 0 when closes are equal; both series use the same smoothing period
Calculation: Floating upper and lower levels = rolling minimum VZO + the respective percentage of the rolling VZO range (maximum − minimum), using the same lookback
Long: VZO > floating upper level
Short: VZO < floating lower level