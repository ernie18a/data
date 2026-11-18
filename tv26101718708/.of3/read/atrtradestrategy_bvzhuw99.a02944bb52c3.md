Calculation: ATR upper band = close[1] on T1 (last completed T1 bar) + ATR(TR, ATR lookback, selected smoothing) on chart bars
Calculation: ATR lower band = close[1] on T1 (last completed T1 bar) - ATR(TR, ATR lookback, selected smoothing) on chart bars
Calculation: ATR midpoint = (ATR upper band + ATR lower band) / 2
Long: year(datetime) > start-year AND position is flat or short AND ((typical-price mode AND (close + high + low) / 3 > ATR upper band) OR (NOT typical-price mode AND close > ATR upper band × long-entry multiplier))
Short: year(datetime) > start-year AND position is long AND ((typical-price mode AND (close + high + low) / 3 < ATR lower band) OR (NOT typical-price mode AND close < ATR lower band))
Exit: long, close < EMA(close, EMA lookback) OR (middle-band exit mode AND close < ATR midpoint) OR low <= entry price − (close × max-loss parameter) ticks
Exit: short, close > EMA(close, EMA lookback) OR (middle-band exit mode AND close > ATR midpoint) OR high >= entry price + (close × max-loss parameter) ticks