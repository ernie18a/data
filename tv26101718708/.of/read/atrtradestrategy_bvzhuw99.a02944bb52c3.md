Calculation: ATR = selected RMA, SMA, EMA, or WMA of true range over the lookback
Calculation: ATR High = last completed daily close + ATR
Calculation: ATR Low = last completed daily close - ATR
Calculation: ATR Mid = (ATR High + ATR Low) / 2
Long: typical price > ATR High if typical-price mode is enabled, otherwise close > 1.01 × ATR High AND year > 2009 AND position size ≤ 0
Short: typical price < ATR Low if typical-price mode is enabled, otherwise close < ATR Low AND year > 2009 AND position size > 0
Exit: long, close < EMA(close) OR (middle-line stop enabled AND close < ATR Mid)
Exit: short, close > EMA(close) OR (middle-line stop enabled AND close > ATR Mid)