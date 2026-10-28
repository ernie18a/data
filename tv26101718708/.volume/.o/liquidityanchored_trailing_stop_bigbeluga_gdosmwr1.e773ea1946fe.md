Calculation: Trend = starts bullish; switches to bearish when source < previous Stop 4, switches to bullish when source > previous Stop 4, otherwise persists
Calculation: Stop 4 = ATR trailing level using the longest offset: in an uptrend, max(source − ATR × (base offset + 3), previous Stop 4); in a downtrend, min(source + ATR × (base offset + 3), previous Stop 4); reset to the new trend's source ± ATR × (base offset + 3) on a trend switch
Long: previous Trend is bearish AND source > previous Stop 4
Short: previous Trend is bullish AND source < previous Stop 4
Exit: long, source < previous Stop 4
Exit: short, source > previous Stop 4