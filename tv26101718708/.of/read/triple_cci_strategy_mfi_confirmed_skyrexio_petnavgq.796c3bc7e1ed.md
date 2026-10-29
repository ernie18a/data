Calculation: Fast CCI = CCI with a shorter lookback than middle and slow CCI
Calculation: Middle CCI = CCI with a shorter lookback than slow CCI
Calculation: Trend EMA = EMA with a longer lookback than trailing EMA
Calculation: Stop level = entry price − ATR × stop multiplier
Calculation: Trailing activation level = entry price + ATR × activation multiplier
Long: Fast CCI crosses above 0 AND middle CCI > 0 AND slow CCI > 0 AND close > trend EMA AND MFI > 50
Exit: Long, low ≤ stop level OR (a bar’s high crosses above the trailing activation level and close < trailing EMA)