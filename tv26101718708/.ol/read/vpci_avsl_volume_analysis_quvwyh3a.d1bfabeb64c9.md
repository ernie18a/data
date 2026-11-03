Calculation: VPCI per mille = 1000 × (VWMA(close, long) − SMA(close, long)) × (VWMA(close, short) / SMA(close, short)) × (SMA(volume, short) / SMA(volume, long)) / close; long lookback is 5× the short lookback; use 1 for either ratio if its denominator is zero, and 0 if close is zero
Calculation: VPCI Bollinger bands = SMA(VPCI per mille, lookback) ± standard-deviation multiplier × standard deviation(VPCI per mille, lookback)
Calculation: AVSL buy level = SMA(low / adjustment, adaptive lookback) − standard-deviation(low / adjustment, adaptive lookback) × adaptive multiplier
Calculation: AVSL sell level = SMA(high × adjustment, adaptive lookback) + standard-deviation(high × adjustment, adaptive lookback) × adaptive multiplier
Calculation: AVSL adjustment = clamp((1 + VPCI per mille / 1000) × (VWMA(close, short) / SMA(close, short)), 0.8, 1.2); use 1 for the ratio if its denominator is zero
Calculation: AVSL adaptive lookback = clamp(round(base lookback + (VPCI per mille / 1000) × 100), 3, 50)
Calculation: AVSL adaptive multiplier = clamp(base multiplier × (1 + VPCI per mille / 1000), 0.5, 4)
Long: VPCI per mille crosses above the lower VPCI Bollinger band AND VPCI per mille was below that band on at least one prior bar since the previous long signal
Short: VPCI per mille crosses below the upper VPCI Bollinger band AND VPCI per mille was above that band on at least one prior bar since the previous short signal
Exit: long, close crosses below the AVSL buy level
Exit: short, close crosses above the AVSL sell level