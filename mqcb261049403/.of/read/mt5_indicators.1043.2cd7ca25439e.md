Calculation: XRSX = 100 × clamp(smoothed change in selected price / smoothed absolute change in selected price, -1, 1), using the same smoothing method and parameters for both series; undefined when the denominator is zero.
Calculation: XRSX signal = the XRSX series smoothed with a separately selected smoothing method and parameters.
Long: chart-timeframe XRSX > 0 AND XRSX > previous-bar XRSX.
Long: chart-timeframe XRSX < 0 AND XRSX > previous-bar XRSX.
Short: chart-timeframe XRSX > 0 AND XRSX < previous-bar XRSX.
Short: chart-timeframe XRSX < 0 AND XRSX < previous-bar XRSX.
Long: chart-timeframe XRSX > previous-bar XRSX signal.
Short: chart-timeframe XRSX < previous-bar XRSX signal.
Long: for any configured higher or chart timeframe, XRSX > XRSX signal on its still-forming bar at the start of that timeframe's bar.
Short: for any configured higher or chart timeframe, XRSX < XRSX signal on its still-forming bar at the start of that timeframe's bar.