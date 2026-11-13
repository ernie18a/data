Calculation: RVWAP = sum(hlc3*volume)/sum(volume) over a rolling window of recent bars on the chart timeframe
Calculation: StDev = sqrt(max(sum(volume*hlc3^2)/sum(volume) - RVWAP^2, 0)) over the same rolling window
Calculation: LowerBand = RVWAP - k*StDev; UpperBand = RVWAP + k*StDev (k > 0 is a fixed multiplier)
Long: close > LowerBand AND close[1] <= LowerBand[1] (close crosses above the lower band), evaluated on the completed bar
Short: close < UpperBand AND close[1] >= UpperBand[1] (close crosses below the upper band), evaluated on the completed bar
Exit: long, high > RVWAP AND high[1] <= RVWAP[1] (high crosses above RVWAP)
Exit: short, low < RVWAP AND low[1] >= RVWAP[1] (low crosses below RVWAP)