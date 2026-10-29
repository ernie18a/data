Calculation: Smoothed Pressure = EMA of the equally weighted average of four close rate-of-change values, using progressively longer lookbacks from fast to macro
Calculation: Adaptive Pressure Threshold = standard deviation of Smoothed Pressure over a longer lookback, multiplied by a threshold factor
Long: Smoothed Pressure > Adaptive Pressure Threshold AND previous bar Smoothed Pressure <= previous bar Adaptive Pressure Threshold AND current chart bar is complete
Short: Smoothed Pressure < -Adaptive Pressure Threshold AND previous bar Smoothed Pressure >= previous bar -Adaptive Pressure Threshold AND current chart bar is complete
Long: Smoothed Pressure > 0 AND previous bar Smoothed Pressure <= 0 AND current chart bar is complete
Short: Smoothed Pressure < 0 AND previous bar Smoothed Pressure >= 0 AND current chart bar is complete