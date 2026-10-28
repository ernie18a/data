Calculation: RVWAP = rolling volume-weighted average of hlc3 (high + low + close) over a configurable window of bars
Calculation: Deviation bands = RVWAP ± configurable multiplier × rolling volume-weighted standard deviation of hlc3 over the same window
Long: close crosses above the lower deviation band
Short: close crosses below the upper deviation band
Exit: long, high crosses above RVWAP
Exit: short, low crosses below RVWAP