Calculation: Upper = RMA(high, ma_length) + ATR(atr_length) * upper_mult; Lower = RMA(high, ma_length) - ATR(atr_length) * lower_mult; lower_mult is greater than upper_mult (tight upper band, wider lower band); both bands use the same ma_length and atr_length on chart-timeframe bars
Calculation: Trend = persistent state, initially 0, evaluated on each completed chart bar: set to +1 if close > Upper, set to -1 if close < Lower, otherwise keep the previous bar's Trend
Long: Trend == +1 AND previous bar's Trend != +1
Short: Trend == -1 AND previous bar's Trend != -1