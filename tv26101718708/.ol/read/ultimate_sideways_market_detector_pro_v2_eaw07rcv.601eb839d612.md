Calculation: Support = price of the latest confirmed pivot low, where the low is below the lows of the pivot lookback bars before and after it
Calculation: Resistance = price of the latest confirmed pivot high, where the high is above the highs of the pivot lookback bars before and after it
Calculation: Range high = highest high over the range lookback bars, including the current bar
Calculation: Range low = lowest low over the range lookback bars, including the current bar
Long: low < Support AND close > Support OR close > Range high AND close > high of the previous bar AND close - Range high >= ATR-scaled fake-breakout threshold
Short: high > Resistance AND close < Resistance OR close < Range low AND close < low of the previous bar AND Range low - close >= ATR-scaled fake-breakout threshold