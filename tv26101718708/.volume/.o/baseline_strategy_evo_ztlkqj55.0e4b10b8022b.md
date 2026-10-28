Calculation: Selected price = close, HL2, HLC3, or OHLC4 of the current bar at the selected resolution; use the bar while it is forming
Calculation: Upper baseline = selected moving-average method applied to high over the lookback, using the same method and lookback as the lower baseline; methods are SMA, EMA, HMA, RMA, WMA, VWMA, ALMA, or the midpoint of the lookback highest and lowest highs
Calculation: Lower baseline = selected moving-average method applied to low over the lookback; for the midpoint method, use the midpoint of the lookback highest and lowest lows
Long: selected price > upper baseline OR (selected price >= lower baseline AND selected price <= upper baseline AND previous direction = long)
Short: selected price < lower baseline OR (selected price >= lower baseline AND selected price <= upper baseline AND previous direction = short)
Exit: long, selected price < lower baseline
Exit: short, selected price > upper baseline