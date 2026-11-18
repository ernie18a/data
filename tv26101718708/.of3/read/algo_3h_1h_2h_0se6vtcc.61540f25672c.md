Calculation: Short EMA = EMA(close, shorter lookback) on T1 bars, sampled on chart bars from the still-forming T1 bar
Calculation: Long EMA T2 = EMA(close, longer lookback) on T2 bars, sampled on chart bars from the still-forming T2 bar
Calculation: Long EMA T3 = EMA(close, the same longer lookback) on T3 bars, sampled on chart bars from the still-forming T3 bar
Long: (Long EMA T2 crosses above Long EMA T3) OR (Short EMA crosses above Long EMA T2 AND Long EMA T2 >= Long EMA T3)
Short: (Long EMA T2 crosses below Long EMA T3) OR (Short EMA crosses below Long EMA T2 AND Long EMA T2 <= Long EMA T3)
Exit: long, Short EMA crosses below Long EMA T2 AND Long EMA T2 > Long EMA T3 AND NOT (Long EMA T2 crosses below Long EMA T3)
Exit: short, Short EMA crosses above Long EMA T2 AND Long EMA T2 < Long EMA T3 AND NOT (Long EMA T2 crosses above Long EMA T3)