Calculation: Extended PVT oscillator = cumulative sum of (close change ÷ previous close × volume) minus the midpoint of its rolling highest and lowest values over the same lookback.
Calculation: VTY = close at the most recent crossing of zero by the Extended PVT oscillator.
Calculation: ATR-adjusted SAR = trend-following SAR whose trend flips when close crosses the previous SAR; initialize trend from the previous candle’s direction, reset the acceleration factor on a flip, and increase it on a new trend extreme up to its maximum. Track the trend’s highest high or lowest low as the extreme point; on a flip, set SAR to the prior extreme point, otherwise move SAR by acceleration factor × ATR(14), upward in an uptrend and downward in a downtrend. Use true range if ATR is unavailable.
Calculation: SSARX = close at the most recent crossing of the ATR-adjusted SAR and close.
Calculation: MAXDRAG = the greater of SSARX and VTY.
Calculation: MINDRAG = the lesser of SSARX and VTY.
Long: close crosses above MAXDRAG OR close crosses above MINDRAG
Short: close crosses below MAXDRAG OR close crosses below MINDRAG
Exit: long, close crosses below MAXDRAG OR close crosses below MINDRAG
Exit: short, close crosses above MAXDRAG OR close crosses above MINDRAG