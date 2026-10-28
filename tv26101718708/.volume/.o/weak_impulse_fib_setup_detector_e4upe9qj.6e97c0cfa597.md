Calculation: Bullish structure break = current high > the last confirmed pivot high from the lookback bars ago; confirm pivot highs using the lookback number of bars on each side
Calculation: Bearish structure break = current low < the last confirmed pivot low from the lookback bars ago; confirm pivot lows using the lookback number of bars on each side
Calculation: Total wick = high − max(close, open) + min(close, open) − low
Long: Bearish structure break AND abs(close − open) > total wick AND close < open AND volume < simple moving average of volume
Short: Bullish structure break AND abs(close − open) > total wick AND close > open AND volume < simple moving average of volume