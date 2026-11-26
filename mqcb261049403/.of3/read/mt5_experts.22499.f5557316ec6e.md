Calculation: Adaptive Renko direction on T1 bars = bearish if the lower Renko level is below its prior-bar value, otherwise bullish if the upper Renko level is above its prior-bar value, otherwise retain its previous direction
Long: Adaptive Renko direction(T1, bar still forming) is bullish AND Adaptive Renko direction(T1, last completed bar) is bearish
Short: Adaptive Renko direction(T1, bar still forming) is bearish AND Adaptive Renko direction(T1, last completed bar) is bullish
Exit: long, Adaptive Renko direction(T1, bar still forming) is bearish
Exit: short, Adaptive Renko direction(T1, bar still forming) is bullish