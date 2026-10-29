Calculation: Stop 4 = Ratcheting trailing stop based on ATR: in an uptrend, the greater of close minus ATR times the widest band multiplier and the prior Stop 4; in a downtrend, the lesser of close plus ATR times the widest band multiplier and the prior Stop 4; reset to the corresponding close-plus-or-minus-ATR offset when trend direction flips
Long: prior trend is down AND close > prior Stop 4
Short: prior trend is up AND close < prior Stop 4
Exit: long, close < prior Stop 4
Exit: short, close > prior Stop 4