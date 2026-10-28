Calculation: Reference high/low = either the highest high/lowest low over the preceding structure lookback bars, excluding the current bar, or the high/low of the last completed daily bar.
Calculation: Volume factor = current volume >= multiplier × average volume of the preceding volume lookback bars.
Calculation: Body factor = abs(close − open) >= body threshold × ATR and, when body direction is required, close > open for an upward breakout or close < open for a downward breakout.
Calculation: Pressure factor = sum over the pressure lookback bars, including the current bar, of volume × (2 × (close − low)/(high − low) − 1), using 0 when high = low, divided by (average volume of the preceding volume lookback bars × pressure lookback); this value >= pressure threshold for an upward breakout or <= −pressure threshold for a downward breakout.
Calculation: Close extension factor = (close − broken level)/ATR for an upward breakout or (broken level − close)/ATR for a downward breakout; it >= the close extension threshold.
Calculation: Breakout score = count of true Volume, Body, Pressure, and Close extension factors.
Long: high > reference high AND close > reference high AND breakout score >= 3
Short: low < reference low AND close < reference low AND breakout score >= 3