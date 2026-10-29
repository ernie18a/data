Calculation: Strict pivot low = the previous bar has a lower low and lower high than both adjacent bars
Calculation: Strict pivot high = the previous bar has a higher high and higher low than both adjacent bars
Calculation: +DI = 100 × RMA(positive directional movement, ADX lookback) / RMA(true range, ADX lookback)
Calculation: −DI = 100 × RMA(negative directional movement, ADX lookback) / RMA(true range, ADX lookback)
Calculation: DX = 100 × abs(+DI − −DI) / (+DI + −DI)
Calculation: ADX = RMA(DX, ADX lookback)
Long: Strict pivot low
Long: Strict pivot low AND previous bar range ≥ ATR × minimum pivot-size multiple AND strict pivot low on the last completed higher-timeframe bar AND (SMA filter disabled OR close > close SMA) AND ADX > threshold AND ATR > its SMA with a shorter lookback than the ATR lookback AND within the configured session AND position is flat or short
Short: Strict pivot high
Short: Strict pivot high AND previous bar range ≥ ATR × minimum pivot-size multiple AND strict pivot high on the last completed higher-timeframe bar AND (SMA filter disabled OR close < close SMA) AND ADX > threshold AND ATR > its SMA with a shorter lookback than the ATR lookback AND within the configured session AND position is flat or long
Exit: Long, high ≥ entry price + ATR-at-entry × target multiple rounded to the nearest tick OR low ≤ entry price − ATR-at-entry × stop multiple rounded to the nearest tick OR short-entry condition
Exit: Short, low ≤ entry price − ATR-at-entry × target multiple rounded to the nearest tick OR high ≥ entry price + ATR-at-entry × stop multiple rounded to the nearest tick OR long-entry condition